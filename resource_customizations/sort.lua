-- Example conditions array (replace with your actual data)
local conditions = {
    {type = "Synced", lastUpdateTime = "2024-11-15T14:17:38Z", status = 'False'},
    {type = "Ready", lastUpdateTime = "2024-10-10T19:36:11Z", status = 'True'},
    {type = "LastAsyncOperation", lastUpdateTime = "2024-11-15T14:17:38Z", status = 'False'}
}

-- Function to convert a date string into a timestamp for comparison
local function to_timestamp(date_str)
    return os.time({year = string.sub(date_str, 1, 4),
                    month = string.sub(date_str, 6, 7),
                    day = string.sub(date_str, 9, 10),
                    hour = string.sub(date_str, 12, 13),
                    min = string.sub(date_str, 15, 16),
                    sec = string.sub(date_str, 18, 19),
                    isdst = false})
end

-- Custom sorting function based on the 'lastUpdateTime' field
table.sort(conditions, function(a, b)
    local time_a = to_timestamp(a.lastUpdateTime)
    local time_b = to_timestamp(b.lastUpdateTime)
    return time_a < time_b  -- Sort in ascending order (earliest first)
end)

-- Print the sorted conditions
for _, condition in ipairs(conditions) do
    print(condition.lastUpdateTime,condition.type)
end
