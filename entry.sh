#!/bin/sh

: "${UID:=1000}"
: "${GID:=1000}"
if [ "$(id -u vintagestory)" -ne "$UID" ]; then usermod -o -u "$UID" vintagestory ; fi
if [ "$(id -g vintagestory)" -ne "$GID" ]; then groupmod -o -g "$GID" vintagestory ; fi

VERSION_FILE="/data/vintage/.version"
SERVER_DLL="/data/StratumServer"
SERVER_CONFIG="/data/vintage/serverconfig.json"

# Seed the config from the baked-in default the first time (nothing to edit otherwise).
if [ ! -f "$SERVER_CONFIG" ]; then
    echo "No config at $SERVER_CONFIG, seeding from default-serverconfig.json..."
    mkdir -p "$(dirname "$SERVER_CONFIG")"
    cp /data/default-serverconfig.json "$SERVER_CONFIG"
fi

jq_parse() {
    # jq_parse <jq-path> <type: str|num|bool> <value>   (empty/unset value is a no-op)
    [ -n "$3" ] || return 0
    case "$2" in
        str)  expr="$1 = \$v" ;;
        num)  expr="$1 = (\$v | tonumber)" ;;
        bool) expr="$1 = (\$v == \"true\")" ;;
        *)    echo "jq_parse: unknown type '$2' for $1" >&2; return 1 ;;
    esac
    # Capture jq's output first: a jq failure must never truncate the config to empty.
    if updated=$(jq "$expr" --arg v "$3" "$SERVER_CONFIG"); then
        printf '%s\n' "$updated" > "$SERVER_CONFIG"
    else
        echo "jq_parse: failed to set $1 ($2=$3)" >&2
        return 1
    fi
}

# ENV_VAR | jq-path | type(str|num|bool)   -- keep rows flush-left (leading space breaks the key)
# NOTE: VS stores most WorldConfiguration values as STRINGS even when numeric, so they are typed `str`.
config_mapping='
# --- General ---
SERVER_NAME|.ServerName|str
SERVER_DESCRIPTION|.ServerDescription|str
SERVER_MOTD|.WelcomeMessage|str
SERVER_LANGUAGE|.ServerLanguage|str
SERVER_MASTERSERVER_URL|.MasterserverUrl|str
SERVER_MODDB_URL|.ModDbUrl|str
SERVER_STARTUP_COMMANDS|.StartupCommands|str
SERVER_DEFAULT_ROLE_CODE|.DefaultRoleCode|str
# --- Network ---
SERVER_IP|.Ip|str
SERVER_PORT|.Port|num
SERVER_UPNP|.Upnp|bool
SERVER_ADVERTISE|.AdvertiseServer|bool
SERVER_VERIFY_PLAYER_AUTH|.VerifyPlayerAuth|bool
SERVER_CLIENT_CONNECTION_TIMEOUT|.ClientConnectionTimeout|num
# --- Players / access ---
SERVER_MAX_CLIENTS|.MaxClients|num
SERVER_MAX_CLIENTS_IN_QUEUE|.MaxClientsInQueue|num
SERVER_PASSWORD|.Password|str
SERVER_WHITELIST_MODE|.WhitelistMode|num
SERVER_LOGIN_FLOOD_PROTECTION|.LoginFloodProtection|bool
SERVER_CHAT_RATE_LIMIT_MS|.ChatRateLimitMs|num
SERVER_MAX_OWNED_GROUP_CHANNELS_PER_USER|.MaxOwnedGroupChannelsPerUser|num
# --- Gameplay toggles ---
SERVER_PVP|.AllowPvP|bool
SERVER_FIRE_SPREAD|.AllowFireSpread|bool
SERVER_FALLING_BLOCKS|.AllowFallingBlocks|bool
SERVER_PASS_TIME_WHEN_EMPTY|.PassTimeWhenEmpty|bool
# --- Modes / debug ---
SERVER_HOSTED_MODE|.HostedMode|bool
SERVER_HOSTED_MODE_ALLOW_MODS|.HostedModeAllowMods|bool
SERVER_ENTITY_DEBUG_MODE|.EntityDebugMode|bool
SERVER_COMPRESS_PACKETS|.CompressPackets|bool
SERVER_ANTI_ABUSE|.AntiAbuse|num
SERVER_LOG_BLOCK_BREAK_PLACE|.LogBlockBreakPlace|bool
SERVER_DISABLE_MOD_SAFETY_CHECK|.DisableModSafetyCheck|bool
# --- World size ---
SERVER_MAP_SIZE_X|.MapSizeX|num
SERVER_MAP_SIZE_Y|.MapSizeY|num
SERVER_MAP_SIZE_Z|.MapSizeZ|num
SERVER_MAX_CHUNK_RADIUS|.MaxChunkRadius|num
# --- Watchdog / shutdown limits ---
SERVER_DIE_BELOW_DISK_SPACE|.DieBelowDiskSpaceMb|num
SERVER_DIE_ABOVE_ERROR_COUNT|.DieAboveErrorCount|num
SERVER_DIE_ABOVE_MEMORY_USAGE|.DieAboveMemoryUsageMb|num
SERVER_LOG_FILE_SPLIT_AFTER_LINE|.LogFileSplitAfterLine|num
# --- Performance / ticking ---
SERVER_SPAWN_CAP_PLAYER_SCALING|.SpawnCapPlayerScaling|num
SERVER_MAX_MAIN_THREAD_BLOCK_TICKS|.MaxMainThreadBlockTicks|num
SERVER_RANDOM_BLOCK_TICKS_PER_CHUNK|.RandomBlockTicksPerChunk|num
SERVER_TICK_TIME|.TickTime|num
SERVER_BLOCK_TICK_CHUNK_RANGE|.BlockTickChunkRange|num
SERVER_BLOCK_TICK_INTERVAL|.BlockTickInterval|num
# --- World corruption / testing ---
SERVER_SKIP_EVERY_CHUNK_ROW|.SkipEveryChunkRow|num
SERVER_SKIP_EVERY_CHUNK_ROW_WIDTH|.SkipEveryChunkRowWidth|num
SERVER_CORRUPTION_PROTECTION|.CorruptionProtection|bool
SERVER_REGENERATE_CORRUPT_CHUNKS|.RegenerateCorruptChunks|bool
# --- World setup (.WorldConfig.*) ---
SERVER_WORLD_SEED|.WorldConfig.Seed|str
SERVER_WORLD_NAME|.WorldConfig.WorldName|str
SERVER_WORLD_TYPE|.WorldConfig.WorldType|str
SERVER_WORLD_PLAY_STYLE|.WorldConfig.PlayStyle|str
SERVER_WORLD_PLAY_STYLE_LANG_CODE|.WorldConfig.PlayStyleLangCode|str
SERVER_WORLD_ALLOW_CREATIVE_MODE|.WorldConfig.AllowCreativeMode|bool
SERVER_WORLD_MAP_SIZE_Y|.WorldConfig.MapSizeY|num
# --- World generation (.WorldConfig.WorldConfiguration.*) ---
WORLDCONFIG_GAMEMODE|.WorldConfig.WorldConfiguration.gameMode|str
WORLDCONFIG_STARTING_CLIMATE|.WorldConfig.WorldConfiguration.startingClimate|str
WORLDCONFIG_SPAWN_RADIUS|.WorldConfig.WorldConfiguration.spawnRadius|str
WORLDCONFIG_GRACE_TIMER|.WorldConfig.WorldConfiguration.graceTimer|str
WORLDCONFIG_DEATH_PUNISHMENT|.WorldConfig.WorldConfiguration.deathPunishment|str
WORLDCONFIG_DROPPED_ITEMS_TIMER|.WorldConfig.WorldConfiguration.droppedItemsTimer|str
WORLDCONFIG_SEASONS|.WorldConfig.WorldConfiguration.seasons|str
WORLDCONFIG_PLAYERLIVES|.WorldConfig.WorldConfiguration.playerlives|str
WORLDCONFIG_LUNG_CAPACITY|.WorldConfig.WorldConfiguration.lungCapacity|str
WORLDCONFIG_DAYS_PER_MONTH|.WorldConfig.WorldConfiguration.daysPerMonth|str
WORLDCONFIG_HARSH_WINTERS|.WorldConfig.WorldConfiguration.harshWinters|str
WORLDCONFIG_BLOCK_GRAVITY|.WorldConfig.WorldConfiguration.blockGravity|str
WORLDCONFIG_CAVE_INS|.WorldConfig.WorldConfiguration.caveIns|str
WORLDCONFIG_ALLOW_UNDERGROUND_FARMING|.WorldConfig.WorldConfiguration.allowUndergroundFarming|bool
WORLDCONFIG_NO_LIQUID_SOURCE_TRANSPORT|.WorldConfig.WorldConfiguration.noLiquidSourceTransport|bool
WORLDCONFIG_BODY_TEMPERATURE_RESISTANCE|.WorldConfig.WorldConfiguration.bodyTemperatureResistance|str
WORLDCONFIG_CREATURE_HOSTILITY|.WorldConfig.WorldConfiguration.creatureHostility|str
WORLDCONFIG_CREATURE_STRENGTH|.WorldConfig.WorldConfiguration.creatureStrength|str
WORLDCONFIG_CREATURE_SWIM_SPEED|.WorldConfig.WorldConfiguration.creatureSwimSpeed|str
WORLDCONFIG_PLAYER_HEALTH_POINTS|.WorldConfig.WorldConfiguration.playerHealthPoints|str
WORLDCONFIG_PLAYER_HUNGER_SPEED|.WorldConfig.WorldConfiguration.playerHungerSpeed|str
WORLDCONFIG_PLAYER_HEALTH_REGEN_SPEED|.WorldConfig.WorldConfiguration.playerHealthRegenSpeed|str
WORLDCONFIG_PLAYER_MOVE_SPEED|.WorldConfig.WorldConfiguration.playerMoveSpeed|str
WORLDCONFIG_FOOD_SPOIL_SPEED|.WorldConfig.WorldConfiguration.foodSpoilSpeed|str
WORLDCONFIG_SAPLING_GROWTH_RATE|.WorldConfig.WorldConfiguration.saplingGrowthRate|str
WORLDCONFIG_TOOL_DURABILITY|.WorldConfig.WorldConfiguration.toolDurability|str
WORLDCONFIG_TOOL_MINING_SPEED|.WorldConfig.WorldConfiguration.toolMiningSpeed|str
WORLDCONFIG_PROPICK_NODE_SEARCH_RADIUS|.WorldConfig.WorldConfiguration.propickNodeSearchRadius|str
WORLDCONFIG_MICROBLOCK_CHISELING|.WorldConfig.WorldConfiguration.microblockChiseling|str
WORLDCONFIG_ALLOW_COORDINATE_HUD|.WorldConfig.WorldConfiguration.allowCoordinateHud|bool
WORLDCONFIG_ALLOW_MAP|.WorldConfig.WorldConfiguration.allowMap|bool
WORLDCONFIG_COLOR_ACCURATE_WORLDMAP|.WorldConfig.WorldConfiguration.colorAccurateWorldmap|bool
WORLDCONFIG_LORE_CONTENT|.WorldConfig.WorldConfiguration.loreContent|bool
WORLDCONFIG_CLUTTER_OBTAINABLE|.WorldConfig.WorldConfiguration.clutterObtainable|str
WORLDCONFIG_LIGHTNING_FIRES|.WorldConfig.WorldConfiguration.lightningFires|bool
WORLDCONFIG_ALLOW_TIMESWITCH|.WorldConfig.WorldConfiguration.allowTimeswitch|bool
WORLDCONFIG_TEMPORAL_STABILITY|.WorldConfig.WorldConfiguration.temporalStability|bool
WORLDCONFIG_TEMPORAL_STORMS|.WorldConfig.WorldConfiguration.temporalStorms|str
WORLDCONFIG_TEMPSTORM_DURATION_MUL|.WorldConfig.WorldConfiguration.tempstormDurationMul|str
WORLDCONFIG_TEMPORAL_RIFTS|.WorldConfig.WorldConfiguration.temporalRifts|str
WORLDCONFIG_TEMPORAL_GEAR_RESPAWN_USES|.WorldConfig.WorldConfiguration.temporalGearRespawnUses|str
WORLDCONFIG_TEMPORAL_STORM_SLEEPING|.WorldConfig.WorldConfiguration.temporalStormSleeping|str
WORLDCONFIG_WORLD_CLIMATE|.WorldConfig.WorldConfiguration.worldClimate|str
WORLDCONFIG_LANDCOVER|.WorldConfig.WorldConfiguration.landcover|str
WORLDCONFIG_OCEANSCALE|.WorldConfig.WorldConfiguration.oceanscale|str
WORLDCONFIG_UPHEAVEL_COMMONNESS|.WorldConfig.WorldConfiguration.upheavelCommonness|str
WORLDCONFIG_GEOLOGIC_ACTIVITY|.WorldConfig.WorldConfiguration.geologicActivity|str
WORLDCONFIG_LANDFORM_SCALE|.WorldConfig.WorldConfiguration.landformScale|str
WORLDCONFIG_WORLD_WIDTH|.WorldConfig.WorldConfiguration.worldWidth|str
WORLDCONFIG_WORLD_LENGTH|.WorldConfig.WorldConfiguration.worldLength|str
WORLDCONFIG_WORLD_EDGE|.WorldConfig.WorldConfiguration.worldEdge|str
WORLDCONFIG_POLAR_EQUATOR_DISTANCE|.WorldConfig.WorldConfiguration.polarEquatorDistance|str
WORLDCONFIG_GLOBAL_TEMPERATURE|.WorldConfig.WorldConfiguration.globalTemperature|str
WORLDCONFIG_GLOBAL_PRECIPITATION|.WorldConfig.WorldConfiguration.globalPrecipitation|str
WORLDCONFIG_GLOBAL_FORESTATION|.WorldConfig.WorldConfiguration.globalForestation|str
WORLDCONFIG_GLOBAL_DEPOSIT_SPAWN_RATE|.WorldConfig.WorldConfiguration.globalDepositSpawnRate|str
WORLDCONFIG_SURFACE_COPPER_DEPOSITS|.WorldConfig.WorldConfiguration.surfaceCopperDeposits|str
WORLDCONFIG_SURFACE_TIN_DEPOSITS|.WorldConfig.WorldConfiguration.surfaceTinDeposits|str
WORLDCONFIG_SNOW_ACCUM|.WorldConfig.WorldConfiguration.snowAccum|str
WORLDCONFIG_ALLOW_LAND_CLAIMING|.WorldConfig.WorldConfiguration.allowLandClaiming|bool
WORLDCONFIG_CLASS_EXCLUSIVE_RECIPES|.WorldConfig.WorldConfiguration.classExclusiveRecipes|bool
WORLDCONFIG_AUCTION_HOUSE|.WorldConfig.WorldConfiguration.auctionHouse|bool
'

# shove the whole config mapping through the jq parser
while IFS='|' read -r key path type; do
    case "$key" in ''|\#*) continue ;; esac   # skip blank lines and # comments
    jq_parse "$path" "$type" "$(printenv "$key" || true)"
done <<EOF
$config_mapping
EOF

chown -R vintagestory:vintagestory /data

# Start server
echo "Launching server..."
cd /data
exec su vintagestory -s /bin/sh -p -c "
  [ -p /tmp/vsserver-log ] || mkfifo /tmp/vsserver-log
  cat /tmp/vsserver-log &
  screen -DmS vsserver script -f -q -c 'chmod +x ${SERVER_DLL}; ${SERVER_DLL} --dataPath /data/vintage' /tmp/vsserver-log
"
