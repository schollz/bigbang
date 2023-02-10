-- bigbang

engine.name="BigBang"

function choose(t)
  return t[math.random(1,#t)]
end

function scramble(tbl)
  for i=#tbl,2,-1 do
    local j=math.random(i)
    tbl[i],tbl[j]=tbl[j],tbl[i]
  end
end

function init()
  seeds={1,1,1,1}
  scale={0,2,4,5,7,9,11}
  timeScale=4
  for i=1,3 do
    for _,v in ipairs(scale) do
      table.insert(scale,v+12*i)
    end
  end
  clock.run(function()
    local j=-1
    while true do
      j=j+1
      if j%4==0 then
        -- choose new seeds
        seeds={math.random(1,100),math.random(1,100),math.random(1,100),math.random(1,100)}
        print("seeds")
        tab.print(seeds)
        redraw()
      end
      -- determine random
      math.randomseed(seeds[j%#seeds+1])
      local sleeptime=6*(1.5+(0.25*math.random(0,7)))*timeScale/8
      local spaces=scramble(choose({
        {4,3,2},
        {3,2,1},
        {2,2,3},
        {3,4,5},
      }))
      -- root note
      table.insert(spaces,1,math.random(1,8))
      for i,v in ipairs(spaces) do
        if i>0 then
          spaces[i]=spaces[i]+spaces[i-1]
        else
          -- play root note
          engine.jp2(timeScale,scale[spaces[i]]%12+24)
        end
        -- play other notes
        engine.sine(timeScale,scale[spaces[i]]+48)
      end
      clock.sleep(sleeptime)
      engine.off()
    end
  end)
end

function redraw()
  screen.clear()
  screen.move(64,32)
  screen.text_center(string.format("%d-%d-%d-%d",seeds[1],seeds[2],seeds[3],seeds[4]))
  screen.update()
end
