-- ==============================================================================
-- مشروع تحليل بيانات الطاقة الشمسية (Solar Energy Project)
-- ملف التحليل الاستكشافي للبيانات باستخدام SQL (Exploratory Data Analysis - EDA)
-- المسار: C:\Users\Albostan\solar_project\final_data\solar_analysis.sql
-- ==============================================================================
-- ملاحظة: يمكنك تشغيل هذه الاستعلامات مباشرة عبر DuckDB على ملفات CSV
-- دون الحاجة لتحميلها مسبقاً في قاعدة بيانات.
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- 1. معاينة سريعة للجداول الأربعة وإجمالي عدد السجلات
-- ------------------------------------------------------------------------------

-- أ) جدول مواصفات الأنظمة (Metadata)
SELECT * FROM 'systems_metadata.csv';

-- ب) معاينة أول 10 صفوف من قراءات النظام 1433
SELECT * FROM 'system_1433.csv' LIMIT 10;

-- ج) إجمالي عدد الصفوف في كل ملف
SELECT 'Metadata' AS file_name, COUNT(*) AS row_count FROM 'systems_metadata.csv'
UNION ALL
SELECT 'System 1433', COUNT(*) FROM 'system_1433.csv'
UNION ALL
SELECT 'System 10', COUNT(*) FROM 'system_10.csv'
UNION ALL
SELECT 'System 4', COUNT(*) FROM 'system_4.csv';


-- ------------------------------------------------------------------------------
-- 2. مقارنة شاملة لإنتاج الطاقة والإشعاع بين الأنظمة الثلاثة
-- ------------------------------------------------------------------------------
SELECT 
    'System 1433 (RSF1 - 449.28 kW)' AS system_name,
    COUNT(*) AS total_points,
    ROUND(AVG(ac_power_w), 2) AS avg_power_w,
    ROUND(MAX(ac_power_w), 2) AS max_power_w,
    ROUND(AVG(irradiance), 2) AS avg_irradiance_w_m2,
    ROUND(MAX(irradiance), 2) AS max_irradiance_w_m2,
    ROUND(AVG(module_temp), 2) AS avg_module_temp_c
FROM 'system_1433.csv'
WHERE irradiance > 0  -- التركيز على فترات سطوع الشمس فقط

UNION ALL

SELECT 
    'System 10 (CIS - 1.12 kW)',
    COUNT(*),
    ROUND(AVG(ac_power_w), 2),
    ROUND(MAX(ac_power_w), 2),
    ROUND(AVG(irradiance), 2),
    ROUND(MAX(irradiance), 2),
    ROUND(AVG(module_temp), 2)
FROM 'system_10.csv'
WHERE irradiance > 0

UNION ALL

SELECT 
    'System 4 (x-Si - 1.0 kW)',
    COUNT(*),
    ROUND(AVG(ac_power_w), 2),
    ROUND(MAX(ac_power_w), 2),
    ROUND(AVG(irradiance), 2),
    ROUND(MAX(irradiance), 2),
    ROUND(AVG(module_temp), 2)
FROM 'system_4.csv'
WHERE irradiance > 0;


-- ------------------------------------------------------------------------------
-- 3. تحليل ساعات الذروة اليومية (Hourly Profile / Diurnal Cycle)
-- استخراج متوسط القدرة وشدة الإشعاع ودرجة الحرارة حسب ساعة اليوم (0 إلى 23)
-- ------------------------------------------------------------------------------
SELECT 
    EXTRACT(HOUR FROM CAST(timestamp_local AS TIMESTAMP)) AS hour_of_day,
    ROUND(AVG(ac_power_w), 2) AS avg_ac_power_w,
    ROUND(AVG(irradiance), 2) AS avg_irradiance_w_m2,
    ROUND(AVG(module_temp), 2) AS avg_module_temp_c,
    ROUND(AVG(ambient_temp), 2) AS avg_ambient_temp_c
FROM 'system_1433.csv'
GROUP BY hour_of_day
ORDER BY hour_of_day;


-- ------------------------------------------------------------------------------
-- 4. التحليل الموسمي والشهري (Monthly & Seasonal Energy Generation)
-- حساب إجمالي الطاقة التقديرية بالكيلوواط ساعة (kWh) شهرياً
-- ------------------------------------------------------------------------------
SELECT 
    EXTRACT(YEAR FROM CAST(timestamp_local AS TIMESTAMP)) AS year,
    EXTRACT(MONTH FROM CAST(timestamp_local AS TIMESTAMP)) AS month,
    COUNT(*) AS readings_count,
    ROUND(AVG(ac_power_w), 2) AS avg_power_w,
    ROUND(MAX(ac_power_w), 2) AS peak_power_w,
    ROUND(SUM(ac_power_w * 0.25) / 1000, 2) AS total_kwh  -- النظام 1433 قراءته كل ربع ساعة (0.25h)
FROM 'system_1433.csv'
GROUP BY year, month
ORDER BY year, month;


-- ------------------------------------------------------------------------------
-- 5. فحص تأثير درجة حرارة الألواح على الكفاءة والإنتاج
-- تقسيم درجات حرارة الألواح إلى فئات ومقارنة معدل التوليد لكل W/m² من الإشعاع
-- ------------------------------------------------------------------------------
SELECT 
    CASE 
        WHEN module_temp < 10 THEN '1. بارد جداً (< 10°C)'
        WHEN module_temp BETWEEN 10 AND 25 THEN '2. معتدل (10°C - 25°C)'
        WHEN module_temp BETWEEN 25 AND 40 THEN '3. دافئ (25°C - 40°C)'
        WHEN module_temp BETWEEN 40 AND 55 THEN '4. حار (40°C - 55°C)'
        ELSE '5. حار جداً (> 55°C)'
    END AS temp_range,
    COUNT(*) AS sample_count,
    ROUND(AVG(ac_power_w), 2) AS avg_power_w,
    ROUND(AVG(irradiance), 2) AS avg_irradiance,
    -- نسبة القدرة المولدة مقارنة بالإشعاع (Power-to-Irradiance Ratio)
    ROUND(AVG(ac_power_w / NULLIF(irradiance, 0)), 3) AS power_per_irradiance_ratio
FROM 'system_1433.csv'
WHERE irradiance > 200  -- استبعاد القراءات الضعيفة جداً للتركيز على فترات العمل الفعلية
GROUP BY temp_range
ORDER BY temp_range;


-- ------------------------------------------------------------------------------
-- 6. فحص جودة البيانات والأخطاء التشغيلية (Quality Flags Audit)
-- ------------------------------------------------------------------------------
SELECT 
    COUNT(*) AS total_rows,
    SUM(CASE WHEN is_night_offset THEN 1 ELSE 0 END) AS night_offset_rows,
    SUM(CASE WHEN is_outlier_power THEN 1 ELSE 0 END) AS outlier_rows,
    SUM(CASE WHEN is_over_capacity THEN 1 ELSE 0 END) AS over_capacity_rows,
    SUM(CASE WHEN is_daylight_missing_power THEN 1 ELSE 0 END) AS daylight_missing_power_rows,
    SUM(CASE WHEN is_irradiance_missing THEN 1 ELSE 0 END) AS irradiance_missing_rows
FROM 'system_1433.csv';
