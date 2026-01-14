#!/usr/bin/env bash

set -euo pipefail

OPEN_METEO_ENDPOINT="https://api.open-meteo.com/v1/forecast"
REVERSE_GEOCODE_ENDPOINT="https://geocoding-api.open-meteo.com/v1/reverse"

IPAPI_ENDPOINT="${IPAPI_ENDPOINT:-https://ipapi.co/json}"
IPINFO_ENDPOINT="https://ipinfo.io/json"
CACHE_DIR="${XDG_CACHE_HOME:-"$HOME/.cache"}/waybar-weather"
LOCATION_CACHE="$CACHE_DIR/location.json"
WEATHER_CACHE="$CACHE_DIR/weather.json"
LOCATION_TTL=$((12 * 3600))
WEATHER_TTL=600
DEFAULT_ACCURACY_METERS=${DEFAULT_ACCURACY_METERS:-5000}
LAST_LOCATION_ERROR=""
LOCATION_RESULT=""

mkdir -p "$CACHE_DIR"

now_ts() {
	date +%s
}

emit_error() {
	local message=${1:-"weather unavailable"}
	jq -nc --arg text "" --arg tooltip "$message" '{text:$text,tooltip:$tooltip}'
}

weather_icon() {
	local code=$1
	case $code in
		0) echo "" ;;
		1|2) echo "" ;;
		3) echo "" ;;
		45|48) echo "" ;;
		51|53|55|56|57) echo "" ;;
		61|63|65) echo "" ;;
		66|67) echo "" ;;
		71|73|75|77) echo "" ;;
		80|81|82) echo "" ;;
		85|86) echo "" ;;
		95|96|99) echo "" ;;
		*) echo "" ;;
	esac
}

read_cache_if_fresh() {
	local file=$1 ttl=$2
	[[ -f $file ]] || return 1
	local age shell_ts
	shell_ts=$(stat -c %Y "$file" 2>/dev/null || echo 0)
	age=$(( $(now_ts) - shell_ts ))
	(( age < ttl )) || return 1
	cat "$file"
}

fetch_location() {
	local provider response lat lon accuracy city region country curl_status
	if [[ -n ${IPINFO_TOKEN:-} ]]; then
		provider="ipinfo"
		set +e
		response=$(curl -fsS --max-time 6 "$IPINFO_ENDPOINT?token=$IPINFO_TOKEN")
		curl_status=$?
		set -e
	else
		provider="ipapi"
		set +e
		response=$(curl -fsS --max-time 6 "$IPAPI_ENDPOINT")
		curl_status=$?
		set -e
	fi

	if (( curl_status != 0 )); then
		LAST_LOCATION_ERROR="IP-based geolocation request failed ($provider)."
		return 1
	fi

	if [[ $provider == "ipinfo" ]]; then
		local loc
		loc=$(jq -r '.loc // empty' <<<"$response")
		if [[ $loc == *,* ]]; then
			lat=${loc%,*}
			lon=${loc#*,}
		fi
		city=$(jq -r '.city // empty' <<<"$response")
		region=$(jq -r '.region // empty' <<<"$response")
		country=$(jq -r '.country // empty' <<<"$response")
		accuracy=$(jq -r '.accuracy // empty' <<<"$response")
	else
		lat=$(jq -r '.latitude // empty' <<<"$response")
		lon=$(jq -r '.longitude // empty' <<<"$response")
		city=$(jq -r '.city // empty' <<<"$response")
		region=$(jq -r '.region // empty' <<<"$response")
		country=$(jq -r '.country_code // empty' <<<"$response")
		accuracy=$(jq -r '.accuracy // empty' <<<"$response")
	fi

	if [[ -z $lat || -z $lon ]]; then
		LAST_LOCATION_ERROR="IP-based geolocation returned no coordinates ($provider)."
		return 1
	fi

	local data
	data=$(jq -nc \
		--arg lat "$lat" \
		--arg lon "$lon" \
		--arg accuracy "${accuracy:-$DEFAULT_ACCURACY_METERS}" \
		--arg provider "$provider" \
		--arg city "$city" \
		--arg region "$region" \
		--arg country "$country" \
		--arg timestamp "$(now_ts)" \
		'{lat:($lat|tonumber),lon:($lon|tonumber),accuracy:($accuracy|tonumber),provider:$provider,city:$city,region:$region,country:$country,timestamp:($timestamp|tonumber)}') || return 1

	printf '%s' "$data" > "$LOCATION_CACHE"
	LOCATION_RESULT=$data
}

get_location() {
	LOCATION_RESULT=""
	local cached
	if cached=$(read_cache_if_fresh "$LOCATION_CACHE" $LOCATION_TTL); then
		LOCATION_RESULT=$cached
		return 0
	fi
	if fetch_location; then
		return 0
	fi
	return 1
}

fetch_weather() {
	local lat=$1 lon=$2
	local weather_raw
	weather_raw=$(curl -fsS --max-time 8 \
		"$OPEN_METEO_ENDPOINT?latitude=$lat&longitude=$lon&current=temperature_2m,apparent_temperature,relative_humidity_2m,weather_code,wind_speed_10m&temperature_unit=celsius&wind_speed_unit=mph&timezone=auto") || return 1

	local data
	data=$(jq -nc \
		--arg lat "$lat" \
		--arg lon "$lon" \
		--arg temp "$(jq -r '.current.temperature_2m' <<<"$weather_raw")" \
		--arg feels "$(jq -r '.current.apparent_temperature' <<<"$weather_raw")" \
		--arg humidity "$(jq -r '.current.relative_humidity_2m' <<<"$weather_raw")" \
		--arg code "$(jq -r '.current.weather_code' <<<"$weather_raw")" \
		--arg wind "$(jq -r '.current.wind_speed_10m' <<<"$weather_raw")" \
		--arg timezone "$(jq -r '.timezone' <<<"$weather_raw")" \
		--arg timestamp "$(now_ts)" \
		'{lat:($lat|tonumber),lon:($lon|tonumber),temperature:($temp|tonumber),feels_like:($feels|tonumber),humidity:($humidity|tonumber),code:($code|tonumber),wind:($wind|tonumber),timezone:$timezone,timestamp:($timestamp|tonumber)}') || return 1

	printf '%s' "$data" > "$WEATHER_CACHE"
	printf '%s' "$data"
}

weather_cache_valid_for() {
	local lat=$1 lon=$2
	[[ -f $WEATHER_CACHE ]] || return 1
	local cache_lat cache_lon cache_ts
	cache_lat=$(jq -r '.lat' "$WEATHER_CACHE" 2>/dev/null || echo "")
	cache_lon=$(jq -r '.lon' "$WEATHER_CACHE" 2>/dev/null || echo "")
	cache_ts=$(jq -r '.timestamp' "$WEATHER_CACHE" 2>/dev/null || echo "0")
	[[ -n $cache_lat && -n $cache_lon ]] || return 1
	local age=$(( $(now_ts) - cache_ts ))
	(( age < WEATHER_TTL )) || return 1
	awk -v a="$cache_lat" -v b="$cache_lon" -v x="$lat" -v y="$lon" 'BEGIN {if (((a-x)*(a-x) + (b-y)*(b-y)) < 0.0001) exit 0; exit 1;}' >/dev/null 2>&1 || return 1
	cat "$WEATHER_CACHE"
}

get_weather() {
	local lat=$1 lon=$2
	weather_cache_valid_for "$lat" "$lon" && return 0
	fetch_weather "$lat" "$lon"
}

reverse_geocode() {
	local lat=$1 lon=$2
	local response
	response=$(curl -fsS --max-time 5 \
		"$REVERSE_GEOCODE_ENDPOINT?latitude=$lat&longitude=$lon&language=en&count=1") || return 1
	jq -nc \
		--arg name "$(jq -r '.results[0].name // empty' <<<"$response")" \
		--arg admin1 "$(jq -r '.results[0].admin1 // empty' <<<"$response")" \
		--arg admin2 "$(jq -r '.results[0].admin2 // empty' <<<"$response")" \
		--arg country "$(jq -r '.results[0].country_code // empty' <<<"$response")" \
		--arg lat "$lat" \
		--arg lon "$lon" \
		'{name:$name,admin1:$admin1,admin2:$admin2,country:$country,lat:($lat|tonumber),lon:($lon|tonumber)}'
}

format_place() {
	local place_json=$1 lat=$2 lon=$3
	local name admin1 admin2 country
	name=$(jq -r '.name' <<<"$place_json")
	admin1=$(jq -r '.admin1' <<<"$place_json")
	admin2=$(jq -r '.admin2' <<<"$place_json")
	country=$(jq -r '.country' <<<"$place_json")

	if [[ -n $name && -n $admin1 ]]; then
		printf "%s, %s" "$name" "$admin1"
	elif [[ -n $name && -n $country ]]; then
		printf "%s, %s" "$name" "$country"
	elif [[ -n $admin2 && -n $admin1 ]]; then
		printf "%s, %s" "$admin2" "$admin1"
	else
		printf "%.3f, %.3f" "$lat" "$lon"
	fi
}

main() {
	local location weather lat lon accuracy place place_name icon text tooltip

	if ! get_location; then
		emit_error "${LAST_LOCATION_ERROR:-Unable to derive Wi-Fi location}" && return
	fi

	location=$LOCATION_RESULT
	lat=$(jq -r '.lat' <<<"$location")
	lon=$(jq -r '.lon' <<<"$location")
	accuracy=$(jq -r '.accuracy' <<<"$location")

	if ! weather=$(get_weather "$lat" "$lon"); then
		emit_error "Unable to fetch weather" && return
	fi

	icon=$(weather_icon "$(jq -r '.code' <<<"$weather")")
	text=$(printf "%s %s°C" "$icon" "$(jq -r '.temperature' <<<"$weather")")

	if place=$(reverse_geocode "$lat" "$lon"); then
		place_name=$(format_place "$place" "$lat" "$lon")
	else
		place_name=$(printf "%.3f, %.3f" "$lat" "$lon")
	fi

	tooltip=$(printf "%s\nFeels like: %s°C\nHumidity: %s%%\nWind: %s mph\nAccuracy: ±%sm" \
		"$place_name" \
		"$(jq -r '.feels_like' <<<"$weather")" \
		"$(jq -r '.humidity' <<<"$weather")" \
		"$(jq -r '.wind' <<<"$weather")" \
		"${accuracy%.*}")

	jq -nc --arg text "$text" --arg tooltip "$tooltip" '{text:$text,tooltip:$tooltip}'
}

main "$@"
