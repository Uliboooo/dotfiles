hl.layout.register("equalcolumns", {
  recalculate = function(ctx)
    local count = #ctx.targets
    if count == 0 then
      return
    end

    for index, target in ipairs(ctx.targets) do
      target:place(ctx:column(index, count))
    end
  end,
})
