INSERT INTO user_devices_cumulated
WITH yesterday AS (
    SELECT
        *
    FROM user_devices_cumulated
    WHERE date = DATE('2022-05-21')
),
devices_events AS (
    SELECT
        we.user_id,
        d.browser_type,
        CAST(DATE_TRUNC('day', we.event_time) AS DATE) AS event_date,
        COUNT(*) AS cnt
    FROM bootcamp.web_events we
    LEFT JOIN bootcamp.devices d
        ON we.device_id = d.device_id
    GROUP BY
        we.user_id,
        d.browser_type,
        CAST(DATE_TRUNC('day', we.event_time) AS DATE)
)
, today AS (
    SELECT
        user_id,
        browser_type,
        event_date
    FROM devices_events
    WHERE event_date = DATE('2022-05-22')
)

SELECT
    COALESCE(y.user_id, t.user_id) AS user_id,
    COALESCE(y.browser_type, t.browser_type) AS browser_type,
    CASE
        WHEN y.dates_active IS NOT NULL THEN ARRAY[t.event_date] || y.dates_active
        ELSE ARRAY[t.event_date]
    END AS dates_active,
    DATE('2022-05-22') AS date
FROM yesterday y
FULL OUTER JOIN today t
    ON y.user_id = t.user_id
    AND y.browser_type = t.browser_type
