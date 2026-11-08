# Solar Project Final Data Dictionary
Generated on: 2026-10-26 11:06:49

## 1. Overview & Dataset Scope
This folder (`final_data/`) contains clean, quality-flagged, modeling-ready time series data for 3 real photovoltaic systems from the NREL PVDAQ public repository (S3 bucket `oedi-data-lake`).

### Systems Summary & Windows Kept
- **System 1433 ([1433] NREL RSF1)**:
  - **Capacity**: 449.28 kW (449,280 W)
  - **Mount**: Fixed roof (Tilt: 10°, Azimuth: 180°)
  - **Data Resolution**: 15 minutes
  - **Exact Window Kept**: `2011-01-01 00:00:00` to `2012-12-31 23:45:00` (Full 24 consecutive months)
  - **Total Rows**: 68,780

- **System 10 (NREL CIS -1)**:
  - **Capacity**: 1.12 kW (1,120 W)
  - **Mount**: Fixed ground (Tilt: 40°, Azimuth: 180°)
  - **Data Resolution**: 1 minute
  - **Exact Windows Kept**: `2018-01-01 00:00:00` to `2018-08-03 23:59:00` and `2019-03-20 00:00:00` to `2019-12-01 23:59:00`
  - **Total Rows**: 679,620

- **System 4 (NREL x-Si -1)**:
  - **Capacity**: 1.00 kW (1,000 W)
  - **Mount**: Fixed ground (Tilt: 40°, Azimuth: 180°)
  - **Data Resolution**: 1 minute
  - **Exact Windows Kept**: `2018-01-01 00:00:00` to `2018-08-03 23:59:00` and `2019-03-20 00:00:00` to `2019-12-01 23:59:00`
  - **Total Rows**: 678,831

---

## 2. Column Specifications & Units
| Column Name | Standard Unit | System 1433 Original Unit | Systems 10 & 4 Original Unit | Description / Quality Notes |
| :--- | :---: | :---: | :---: | :--- |
| `system_id` | Integer | ID | ID | Unique NREL PVDAQ identifier (1433, 10, or 4). |
| `timestamp_local` | String (ISO-8601) | YYYY-MM-DD HH:MM:SS | YYYY-MM-DD HH:MM:SS | Local site time (`America/Denver` / US Mountain Time). |
| `ac_power_w` | **Watts (W)** | **kW** (`kWh_gross*4` scaled by 1000) | **W** | Total system AC power output. Nighttime zero-drift retained as flags; values set to 0.0 where irradiance < 5 W/m². |
| `irradiance` | **W/m²** | **W/m²** (POA) | **W/m²** (POA) | Plane-of-array (POA) solar irradiance. Nighttime zero-drift retained as flags; values set to 0.0 where irradiance < 5 W/m². |
| `module_temp` | **°C** | **°C** | **°C** | Back-of-module temperature (from precision thermocouple sensors). |
| `ambient_temp` | **°C** | **°C** | **°C** | Site ambient dry-bulb temperature. |
| `is_night_offset` | Boolean | - | - | `True` when irradiance < 5 W/m² and power was within sensor offset / tare range. |
| `is_outlier_power` | Boolean | - | - | `True` when an impossible extreme power value was observed (e.g. -100 kW anomaly on 1433). |
| `is_over_capacity` | Boolean | - | - | `True` when `ac_power_w > capacity_w` (e.g. momentary cloud-edge irradiance focusing). |
| `is_daylight_missing_power` | Boolean | - | - | `True` when `irradiance > 50 W/m²` and `ac_power_w <= 0` or null (underperformance / soiling candidate). |
| `is_irradiance_missing` | Boolean | - | - | `True` when raw irradiance reading was null. |

---

## 3. Known Data Gaps (> 1 Hour)
Identified from the raw timeseries before window filtering (from `v2_metrics_summary.json`):

### System 1433 (14 Gaps > 1h, 194 Total Rows Lost)
| Gap # | Start Timestamp (Local) | End Timestamp (Local) | Duration (Hours) | Rows Lost |
| :---: | :--- | :--- | :---: | :---: |
| 1 | 2011-01-27 02:45:00 | 2011-01-27 12:15:00 | 9.5 | 37 |
| 2 | 2011-06-25 07:15:00 | 2011-06-25 16:15:00 | 9.0 | 35 |
| 3 | 2012-03-03 07:45:00 | 2012-03-03 15:15:00 | 7.5 | 29 |
| 4 | 2011-05-14 07:00:00 | 2011-05-14 13:30:00 | 6.5 | 25 |
| 5 | 2012-01-17 03:00:00 | 2012-01-17 07:00:00 | 4.0 | 15 |
| 6 | 2011-07-16 07:15:00 | 2011-07-16 10:00:00 | 2.75 | 10 |
| 7 | 2011-04-08 10:30:00 | 2011-04-08 12:45:00 | 2.25 | 8 |
| 8 | 2012-04-27 01:45:00 | 2012-04-27 04:00:00 | 2.25 | 8 |
| 9 | 2012-04-26 19:30:00 | 2012-04-26 21:15:00 | 1.75 | 6 |
| 10 | 2012-03-03 15:15:00 | 2012-03-03 16:45:00 | 1.5 | 5 |
| 11 | 2011-06-25 16:15:00 | 2011-06-25 17:30:00 | 1.25 | 4 |
| 12 | 2011-07-16 10:00:00 | 2011-07-16 11:15:00 | 1.25 | 4 |
| 13 | 2012-04-25 18:15:00 | 2012-04-25 19:30:00 | 1.25 | 4 |
| 14 | 2012-04-26 21:30:00 | 2012-04-26 22:45:00 | 1.25 | 4 |

### System 10 (344 Gaps > 1h, 156,351 Total Rows Lost)
| Gap # | Start Timestamp (Local) | End Timestamp (Local) | Duration (Hours) | Rows Lost |
| :---: | :--- | :--- | :---: | :---: |
| 1 | 2018-08-31 23:49:00 | 2018-09-09 23:50:00 | 216.02 | 12,960 |
| 2 | 2019-12-02 11:19:00 | 2019-12-10 23:00:00 | 203.68 | 12,220 |
| 3 | 2019-01-03 16:02:00 | 2019-01-06 09:33:00 | 65.52 | 3,930 |
| 4 | 2019-01-31 15:09:00 | 2019-02-03 08:07:00 | 64.97 | 3,897 |
| 5 | 2019-02-03 17:27:00 | 2019-02-06 04:53:00 | 59.43 | 3,565 |
| 6 | 2018-12-31 23:49:00 | 2019-01-03 07:57:00 | 56.13 | 3,367 |
| 7 | 2018-10-09 23:49:00 | 2018-10-11 23:51:00 | 48.03 | 2,881 |
| 8 | 2018-11-09 23:49:00 | 2018-11-11 23:50:00 | 48.02 | 2,880 |
| 9 | 2018-12-05 23:50:00 | 2018-12-07 08:25:00 | 32.58 | 1,954 |
| 10 | 2019-01-18 11:08:00 | 2019-01-19 07:39:00 | 20.52 | 1,230 |
| 11 | 2019-02-13 12:58:00 | 2019-02-14 08:29:00 | 19.52 | 1,170 |
| 12 | 2019-01-08 14:14:00 | 2019-01-09 08:38:00 | 18.4 | 1,103 |
| 13 | 2019-02-19 12:35:00 | 2019-02-20 06:40:00 | 18.08 | 1,084 |
| 14 | 2019-03-14 15:53:00 | 2019-03-15 09:53:00 | 18.0 | 1,079 |
| 15 | 2019-01-12 16:16:00 | 2019-01-13 10:00:00 | 17.73 | 1,063 |
| 16 | 2019-01-07 14:17:00 | 2019-01-08 07:49:00 | 17.53 | 1,051 |
| 17 | 2019-01-06 16:49:00 | 2019-01-07 10:19:00 | 17.5 | 1,049 |
| 18 | 2019-01-20 16:04:00 | 2019-01-21 09:34:00 | 17.5 | 1,049 |
| 19 | 2019-01-22 14:05:00 | 2019-01-23 07:29:00 | 17.4 | 1,043 |
| 20 | 2019-01-17 15:00:00 | 2019-01-18 08:23:00 | 17.38 | 1,042 |
| 21 | 2019-01-25 16:04:00 | 2019-01-26 09:23:00 | 17.32 | 1,038 |
| 22 | 2018-12-12 14:29:00 | 2018-12-13 07:46:00 | 17.28 | 1,036 |
| 23 | 2018-12-08 15:02:00 | 2018-12-09 08:18:00 | 17.27 | 1,035 |
| 24 | 2019-01-19 15:50:00 | 2019-01-20 09:06:00 | 17.27 | 1,035 |
| 25 | 2019-02-24 14:15:00 | 2019-02-25 07:29:00 | 17.23 | 1,033 |
| ... | *(Showing top 25 longest of 344 total gaps)* | | | |

### System 4 (40 Gaps > 1h, 197,733 Total Rows Lost)
| Gap # | Start Timestamp (Local) | End Timestamp (Local) | Duration (Hours) | Rows Lost |
| :---: | :--- | :--- | :---: | :---: |
| 1 | 2018-12-14 05:23:00 | 2019-01-29 16:11:00 | 1114.8 | 66,887 |
| 2 | 2018-10-19 05:43:00 | 2018-11-07 08:51:00 | 459.13 | 27,547 |
| 3 | 2018-09-09 23:30:00 | 2018-09-19 13:11:00 | 229.68 | 13,780 |
| 4 | 2019-12-02 11:10:00 | 2019-12-10 22:11:00 | 203.02 | 12,180 |
| 5 | 2019-02-22 05:43:00 | 2019-02-28 23:31:00 | 161.8 | 9,707 |
| 6 | 2019-02-08 05:44:00 | 2019-02-14 10:10:00 | 148.43 | 8,905 |
| 7 | 2018-11-21 04:44:00 | 2018-11-26 08:30:00 | 123.77 | 7,425 |
| 8 | 2018-09-19 17:04:00 | 2018-09-24 07:10:00 | 110.1 | 6,605 |
| 9 | 2018-11-29 21:29:00 | 2018-12-04 09:50:00 | 108.35 | 6,500 |
| 10 | 2018-10-04 23:44:00 | 2018-10-08 07:10:00 | 79.43 | 4,765 |
| 11 | 2018-09-28 05:43:00 | 2018-10-01 08:50:00 | 75.12 | 4,506 |
| 12 | 2018-11-09 12:24:00 | 2018-11-12 11:31:00 | 71.12 | 4,266 |
| 13 | 2018-11-16 22:24:00 | 2018-11-19 07:11:00 | 56.78 | 3,406 |
| 14 | 2019-03-01 23:09:00 | 2019-03-03 23:50:00 | 48.68 | 2,920 |
| 15 | 2018-10-13 06:03:00 | 2018-10-15 06:30:00 | 48.45 | 2,906 |
| 16 | 2018-09-25 15:44:00 | 2018-09-27 06:10:00 | 38.43 | 2,305 |
| 17 | 2019-02-02 23:04:00 | 2019-02-04 08:11:00 | 33.12 | 1,986 |
| 18 | 2018-10-15 16:43:00 | 2018-10-16 10:30:00 | 17.78 | 1,066 |
| 19 | 2018-10-09 14:44:00 | 2018-10-10 07:10:00 | 16.43 | 985 |
| 20 | 2018-11-27 17:43:00 | 2018-11-28 09:30:00 | 15.78 | 946 |
| 21 | 2018-11-08 21:04:00 | 2018-11-09 10:51:00 | 13.78 | 826 |
| 22 | 2018-10-01 17:24:00 | 2018-10-02 06:31:00 | 13.12 | 786 |
| 23 | 2018-11-19 19:44:00 | 2018-11-20 08:31:00 | 12.78 | 766 |
| 24 | 2018-11-14 19:44:00 | 2018-11-15 07:31:00 | 11.78 | 706 |
| 25 | 2018-11-13 22:24:00 | 2018-11-14 09:11:00 | 10.78 | 646 |
| ... | *(Showing top 25 longest of 40 total gaps)* | | | |
