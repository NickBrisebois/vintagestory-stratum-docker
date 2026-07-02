# Vintage Story — Stratum Server (Docker)

A Docker image for running a [Vintage Story](https://www.vintagestory.at/) dedicated
server using the **[Stratum](https://github.com/StratumServer/Stratum)** server
runtime instead of the original game server.

---

## Requirements

- [Docker](https://docs.docker.com/get-docker/) and Docker Compose.

---

## Quick start

```bash
git clone git@github.com:NickBrisebois/vintagestory-stratum-docker.git
cd vintagestory-stratum-docker

# build
docker compose up -d --build

# check logs
docker compose logs -f
```

The first launch generates a default `serverconfig.json` into the data volume, applies any
`SERVER_*` / `WORLDCONFIG_*` environment variables on top of it, and starts the server.

To stop:

```bash
docker compose down
```

---

### Core container variables

| Variable        | Default        | Description                                                                |
| --------------- | -------------- | ------------------------------------------------------------------         |
| `UID`           | `1000`         | User ID the server process runs as (match your host user for bind mounts). |
| `GID`           | `1000`         | Group ID the server process runs as.                                       |
| `SERVER_PORT`   | `42420`        | Game port. Also used by the healthcheck.                                   |

### Server settings (`SERVER_*`)

These map onto top-level keys in `serverconfig.json`.

<details>
<summary><strong>General</strong></summary>

| Variable                    | JSON key            |
| --------------------------- | ------------------- |
| `SERVER_NAME`               | `ServerName`        |
| `SERVER_DESCRIPTION`        | `ServerDescription` |
| `SERVER_MOTD`               | `WelcomeMessage`    |
| `SERVER_LANGUAGE`           | `ServerLanguage`    |
| `SERVER_MASTERSERVER_URL`   | `MasterserverUrl`   |
| `SERVER_MODDB_URL`          | `ModDbUrl`          |
| `SERVER_STARTUP_COMMANDS`   | `StartupCommands`   |
| `SERVER_DEFAULT_ROLE_CODE`  | `DefaultRoleCode`   |

</details>

<details>
<summary><strong>Network</strong></summary>

| Variable                           | JSON key                  |
| ---------------------------------- | ------------------------- |
| `SERVER_IP`                        | `Ip`                      |
| `SERVER_PORT`                      | `Port`                    |
| `SERVER_UPNP`                      | `Upnp`                    |
| `SERVER_ADVERTISE`                 | `AdvertiseServer`         |
| `SERVER_VERIFY_PLAYER_AUTH`        | `VerifyPlayerAuth`        |
| `SERVER_CLIENT_CONNECTION_TIMEOUT` | `ClientConnectionTimeout` |

</details>

<details>
<summary><strong>Players &amp; access</strong></summary>

| Variable                                   | JSON key                       |
| ------------------------------------------ | ------------------------------ |
| `SERVER_MAX_CLIENTS`                       | `MaxClients`                   |
| `SERVER_MAX_CLIENTS_IN_QUEUE`              | `MaxClientsInQueue`            |
| `SERVER_PASSWORD`                          | `Password`                     |
| `SERVER_WHITELIST_MODE`                    | `WhitelistMode`                |
| `SERVER_LOGIN_FLOOD_PROTECTION`            | `LoginFloodProtection`         |
| `SERVER_CHAT_RATE_LIMIT_MS`                | `ChatRateLimitMs`              |
| `SERVER_MAX_OWNED_GROUP_CHANNELS_PER_USER` | `MaxOwnedGroupChannelsPerUser` |

</details>

<details>
<summary><strong>Gameplay toggles</strong></summary>

| Variable                       | JSON key            |
| ------------------------------ | ------------------- |
| `SERVER_PVP`                   | `AllowPvP`          |
| `SERVER_FIRE_SPREAD`           | `AllowFireSpread`   |
| `SERVER_FALLING_BLOCKS`        | `AllowFallingBlocks`|
| `SERVER_PASS_TIME_WHEN_EMPTY`  | `PassTimeWhenEmpty` |

</details>

<details>
<summary><strong>Modes &amp; debug</strong></summary>

| Variable                          | JSON key               |
| --------------------------------- | ---------------------- |
| `SERVER_HOSTED_MODE`              | `HostedMode`           |
| `SERVER_HOSTED_MODE_ALLOW_MODS`   | `HostedModeAllowMods`  |
| `SERVER_ENTITY_DEBUG_MODE`        | `EntityDebugMode`      |
| `SERVER_COMPRESS_PACKETS`         | `CompressPackets`      |
| `SERVER_ANTI_ABUSE`               | `AntiAbuse`            |
| `SERVER_LOG_BLOCK_BREAK_PLACE`    | `LogBlockBreakPlace`   |
| `SERVER_DISABLE_MOD_SAFETY_CHECK` | `DisableModSafetyCheck`|

</details>

<details>
<summary><strong>World size, watchdog, performance &amp; corruption</strong></summary>

| Variable                             | JSON key                   |
| ------------------------------------ | -------------------------- |
| `SERVER_MAP_SIZE_X`                  | `MapSizeX`                 |
| `SERVER_MAP_SIZE_Y`                  | `MapSizeY`                 |
| `SERVER_MAP_SIZE_Z`                  | `MapSizeZ`                 |
| `SERVER_MAX_CHUNK_RADIUS`            | `MaxChunkRadius`           |
| `SERVER_DIE_BELOW_DISK_SPACE`        | `DieBelowDiskSpaceMb`      |
| `SERVER_DIE_ABOVE_ERROR_COUNT`       | `DieAboveErrorCount`       |
| `SERVER_DIE_ABOVE_MEMORY_USAGE`      | `DieAboveMemoryUsageMb`    |
| `SERVER_LOG_FILE_SPLIT_AFTER_LINE`   | `LogFileSplitAfterLine`    |
| `SERVER_SPAWN_CAP_PLAYER_SCALING`    | `SpawnCapPlayerScaling`    |
| `SERVER_MAX_MAIN_THREAD_BLOCK_TICKS` | `MaxMainThreadBlockTicks`  |
| `SERVER_RANDOM_BLOCK_TICKS_PER_CHUNK`| `RandomBlockTicksPerChunk` |
| `SERVER_TICK_TIME`                   | `TickTime`                 |
| `SERVER_BLOCK_TICK_CHUNK_RANGE`      | `BlockTickChunkRange`      |
| `SERVER_BLOCK_TICK_INTERVAL`         | `BlockTickInterval`        |
| `SERVER_SKIP_EVERY_CHUNK_ROW`        | `SkipEveryChunkRow`        |
| `SERVER_SKIP_EVERY_CHUNK_ROW_WIDTH`  | `SkipEveryChunkRowWidth`   |
| `SERVER_CORRUPTION_PROTECTION`       | `CorruptionProtection`     |
| `SERVER_REGENERATE_CORRUPT_CHUNKS`   | `RegenerateCorruptChunks`  |

</details>

<details>
<summary><strong>World setup (<code>WorldConfig.*</code>)</strong></summary>

| Variable                             | JSON key                        |
| ------------------------------------ | ------------------------------- |
| `SERVER_WORLD_SEED`                  | `WorldConfig.Seed`              |
| `SERVER_WORLD_NAME`                  | `WorldConfig.WorldName`         |
| `SERVER_WORLD_TYPE`                  | `WorldConfig.WorldType`         |
| `SERVER_WORLD_PLAY_STYLE`            | `WorldConfig.PlayStyle`         |
| `SERVER_WORLD_PLAY_STYLE_LANG_CODE`  | `WorldConfig.PlayStyleLangCode` |
| `SERVER_WORLD_ALLOW_CREATIVE_MODE`   | `WorldConfig.AllowCreativeMode` |
| `SERVER_WORLD_MAP_SIZE_Y`            | `WorldConfig.MapSizeY`          |

</details>

### World-generation settings (`WORLDCONFIG_*`)

These map onto `WorldConfig.WorldConfiguration.*`. Note that Vintage Story stores most of
these as **strings**, even when the value is numeric — so `"50"`, `"0.5"`, and `"true"` are
all expected here.

> [!NOTE]
> `WorldConfiguration` values only take effect when a world is **first generated**. Changing
> them later won't retroactively rewrite existing terrain. Start a fresh world (delete the
> save / data volume) to apply new world-gen settings.

<details>
<summary><strong>All <code>WORLDCONFIG_*</code> variables</strong></summary>

| Variable                                | World-config key             |
| --------------------------------------- | ---------------------------- |
| `WORLDCONFIG_GAMEMODE`                  | `gameMode`                   |
| `WORLDCONFIG_STARTING_CLIMATE`          | `startingClimate`            |
| `WORLDCONFIG_SPAWN_RADIUS`              | `spawnRadius`                |
| `WORLDCONFIG_GRACE_TIMER`               | `graceTimer`                 |
| `WORLDCONFIG_DEATH_PUNISHMENT`          | `deathPunishment`            |
| `WORLDCONFIG_DROPPED_ITEMS_TIMER`       | `droppedItemsTimer`          |
| `WORLDCONFIG_SEASONS`                   | `seasons`                    |
| `WORLDCONFIG_PLAYERLIVES`               | `playerlives`                |
| `WORLDCONFIG_LUNG_CAPACITY`             | `lungCapacity`               |
| `WORLDCONFIG_DAYS_PER_MONTH`            | `daysPerMonth`               |
| `WORLDCONFIG_HARSH_WINTERS`             | `harshWinters`               |
| `WORLDCONFIG_BLOCK_GRAVITY`             | `blockGravity`               |
| `WORLDCONFIG_CAVE_INS`                  | `caveIns`                    |
| `WORLDCONFIG_ALLOW_UNDERGROUND_FARMING` | `allowUndergroundFarming`    |
| `WORLDCONFIG_NO_LIQUID_SOURCE_TRANSPORT`| `noLiquidSourceTransport`    |
| `WORLDCONFIG_BODY_TEMPERATURE_RESISTANCE`| `bodyTemperatureResistance` |
| `WORLDCONFIG_CREATURE_HOSTILITY`        | `creatureHostility`          |
| `WORLDCONFIG_CREATURE_STRENGTH`         | `creatureStrength`           |
| `WORLDCONFIG_CREATURE_SWIM_SPEED`       | `creatureSwimSpeed`          |
| `WORLDCONFIG_PLAYER_HEALTH_POINTS`      | `playerHealthPoints`         |
| `WORLDCONFIG_PLAYER_HUNGER_SPEED`       | `playerHungerSpeed`          |
| `WORLDCONFIG_PLAYER_HEALTH_REGEN_SPEED` | `playerHealthRegenSpeed`     |
| `WORLDCONFIG_PLAYER_MOVE_SPEED`         | `playerMoveSpeed`            |
| `WORLDCONFIG_FOOD_SPOIL_SPEED`          | `foodSpoilSpeed`             |
| `WORLDCONFIG_SAPLING_GROWTH_RATE`       | `saplingGrowthRate`          |
| `WORLDCONFIG_TOOL_DURABILITY`           | `toolDurability`             |
| `WORLDCONFIG_TOOL_MINING_SPEED`         | `toolMiningSpeed`            |
| `WORLDCONFIG_PROPICK_NODE_SEARCH_RADIUS`| `propickNodeSearchRadius`    |
| `WORLDCONFIG_MICROBLOCK_CHISELING`      | `microblockChiseling`        |
| `WORLDCONFIG_ALLOW_COORDINATE_HUD`      | `allowCoordinateHud`         |
| `WORLDCONFIG_ALLOW_MAP`                 | `allowMap`                   |
| `WORLDCONFIG_COLOR_ACCURATE_WORLDMAP`   | `colorAccurateWorldmap`      |
| `WORLDCONFIG_LORE_CONTENT`              | `loreContent`                |
| `WORLDCONFIG_CLUTTER_OBTAINABLE`        | `clutterObtainable`          |
| `WORLDCONFIG_LIGHTNING_FIRES`           | `lightningFires`             |
| `WORLDCONFIG_ALLOW_TIMESWITCH`          | `allowTimeswitch`            |
| `WORLDCONFIG_TEMPORAL_STABILITY`        | `temporalStability`          |
| `WORLDCONFIG_TEMPORAL_STORMS`           | `temporalStorms`             |
| `WORLDCONFIG_TEMPSTORM_DURATION_MUL`    | `tempstormDurationMul`       |
| `WORLDCONFIG_TEMPORAL_RIFTS`            | `temporalRifts`              |
| `WORLDCONFIG_TEMPORAL_GEAR_RESPAWN_USES`| `temporalGearRespawnUses`    |
| `WORLDCONFIG_TEMPORAL_STORM_SLEEPING`   | `temporalStormSleeping`      |
| `WORLDCONFIG_WORLD_CLIMATE`             | `worldClimate`               |
| `WORLDCONFIG_LANDCOVER`                 | `landcover`                  |
| `WORLDCONFIG_OCEANSCALE`                | `oceanscale`                 |
| `WORLDCONFIG_UPHEAVEL_COMMONNESS`       | `upheavelCommonness`         |
| `WORLDCONFIG_GEOLOGIC_ACTIVITY`         | `geologicActivity`           |
| `WORLDCONFIG_LANDFORM_SCALE`            | `landformScale`              |
| `WORLDCONFIG_WORLD_WIDTH`               | `worldWidth`                 |
| `WORLDCONFIG_WORLD_LENGTH`              | `worldLength`                |
| `WORLDCONFIG_WORLD_EDGE`                | `worldEdge`                  |
| `WORLDCONFIG_POLAR_EQUATOR_DISTANCE`    | `polarEquatorDistance`       |
| `WORLDCONFIG_GLOBAL_TEMPERATURE`        | `globalTemperature`          |
| `WORLDCONFIG_GLOBAL_PRECIPITATION`      | `globalPrecipitation`        |
| `WORLDCONFIG_GLOBAL_FORESTATION`        | `globalForestation`          |
| `WORLDCONFIG_GLOBAL_DEPOSIT_SPAWN_RATE` | `globalDepositSpawnRate`     |
| `WORLDCONFIG_SURFACE_COPPER_DEPOSITS`   | `surfaceCopperDeposits`      |
| `WORLDCONFIG_SURFACE_TIN_DEPOSITS`      | `surfaceTinDeposits`         |
| `WORLDCONFIG_SNOW_ACCUM`                | `snowAccum`                  |
| `WORLDCONFIG_ALLOW_LAND_CLAIMING`       | `allowLandClaiming`          |
| `WORLDCONFIG_CLASS_EXCLUSIVE_RECIPES`   | `classExclusiveRecipes`      |
| `WORLDCONFIG_AUCTION_HOUSE`             | `auctionHouse`               |

</details>

> The complete, authoritative list of supported variables lives in the `config_mapping`
> block in [`entry.sh`](./entry.sh). Any option not listed there must be edited directly in
> `serverconfig.json` inside the data volume.

---

### File ownership

The server runs as a non-root user. Set `UID`/`GID` to match the owner of your `./data`
directory on the host to avoid permission problems on bind mounts (Fedora Cloud instances are created with
a fedora user on top of your created user so you'll get 1001:1001):

```yaml
environment:
  UID: 1000
  GID: 1000
```

---

## Server console

The server runs inside a `screen` session named `vsserver`, so you can attach and issue
in-game admin commands (e.g. `/stop`, `/op <player>`, `/time set day`):

```bash
docker exec -it stratum-server screen -r vsserver
```

Detach without stopping the server with `Ctrl+A` then `D`.

---

## Updating the Stratum version

The Stratum release is pinned in the `Dockerfile` and validated by checksum:

```dockerfile
ENV STRATUM_RELEASE_SHA256="sha256:..." \
    STRATUM_RELEASE_URI="https://github.com/StratumServer/Stratum/releases/download/..."
```

To upgrade:

1. Update `STRATUM_RELEASE_URI` to the desired [Stratum release](https://github.com/StratumServer/Stratum/releases) asset URL.
2. Update `STRATUM_RELEASE_SHA256` to the new archive's `sha256:` digest.
3. Rebuild: `docker compose up -d --build`.

> Back up your `./data` directory before upgrading across game versions.

---

## Healthcheck

The container reports healthy once the game port accepts connections:

```dockerfile
HEALTHCHECK --start-period=1m --interval=5s CMD nc -z 127.0.0.1 "$SERVER_PORT"
```

Check status with `docker ps` (look at the `STATUS` column) or `docker inspect`.

---

## Known Issues

- **Quoting:** Use the Compose mapping form (`KEY: "value"`). The list form (`- KEY="value"`)
  bakes literal quotes into the value and corrupts the generated JSON. See the note in
  [Configuration](#configuration).
- **World-gen changes:** `WORLDCONFIG_*` values only apply to a **freshly generated** world.

---

## Credits

- **[Stratum](https://github.com/StratumServer/Stratum)** — the alternative Vintage Story server runtime this image is built around.
- **[Vintage Story](https://www.vintagestory.at/)** by Anego Studios.
- Originally forked from a Vintage Story server Docker project by **PepeCitron** (see [`LICENSE`](./LICENSE)).

---

## License

Released under the [MIT License](./LICENSE).
