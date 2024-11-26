local health_status = {}

local function contains (table, val)
  for i, v in ipairs(table) do
    if v == val then
      return true
    end
  end
  return false
end

local function to_timestamp(date_str)
  return os.time({year = string.sub(date_str, 1, 4),
                  month = string.sub(date_str, 6, 7),
                  day = string.sub(date_str, 9, 10),
                  hour = string.sub(date_str, 12, 13),
                  min = string.sub(date_str, 15, 16),
                  sec = string.sub(date_str, 18, 19),
                  isdst = false})
end

-- Custom sorting function based on the 'lastTransitionTime' field
table.sort(obj.status.conditions, function(a, b)
  local time_a = to_timestamp(a.lastTransitionTime)
  local time_b = to_timestamp(b.lastTransitionTime)
  return time_a < time_b  -- Sort in ascending order (earliest first)
end)

local has_no_status = {
  "ProviderConfig",
  "ProviderConfigUsage",
  "Composition",
  "CompositionRevision",
  "DeploymentRuntimeConfig",
  "ControllerConfig",
}

if obj.status == nil or next(obj.status) == nil and contains(has_no_status, obj.kind) then
  health_status.status = "Healthy"
  health_status.message = "Resource is up-to-date."
  return health_status
end

if obj.status == nil or next(obj.status) == nil or obj.status.conditions == nil then
  if obj.kind == "ProviderConfig" and obj.status.users ~= nil then
    health_status.status = "Healthy"
    health_status.message = "Resource is in use."
    return health_status
  end
  return health_status
end

-- Shortcut for resources with atProvider state such as repositories.argocd.crossplane.io
if obj.status.atProvider.connectionState then
  if obj.status.atProvider.connectionState.status == "Failed" then
    health_status.status = "Degraded"
    health_status.message = obj.status.atProvider.connectionState.message
    return health_status
  end
end
-- Process all the states in from oldest to newest. (sorted in L26)
for i, condition in ipairs(obj.status.conditions) do
  if condition.type == "LastAsyncOperation" then
    if condition.status == "False" then
      health_status.status = "Degraded"
      health_status.message = condition.message
    end
  end

  if condition.type == "Synced" then
    if condition.status == "False" and string.match(condition.message, "cannot resolve references") then
      health_status.status = "Progressing"
      health_status.message = condition.message
    elseif condition.status == "False" and condition.reason == "ReconcilePaused" then
      health_status.status = "Suspended"
      health_status.message = condition.message
    else
      health_status.status = "Degraded"
      health_status.message = condition.message
    end
  end

  if contains({"Ready", "Healthy", "Offered", "Established"}, condition.type) then
    if condition.status == "True" then
      health_status.status = "Healthy"
      health_status.message = "Resource is up-to-date."
    end
  end
end
return health_status
