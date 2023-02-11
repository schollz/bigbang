-- bigbang

engine.name="BigBang"
seeds={1,1,1,1}
function choose(t)
  return t[math.random(1,#t)]
end

function scramble(tbl)
  for i=#tbl,2,-1 do
    local j=math.random(i)
    tbl[i],tbl[j]=tbl[j],tbl[i]
  end
  return tbl
end

function init()
  scale={}
  timeScale=4
  for i=0,3 do
    for _,v in ipairs({0,2,4,5,7,9,11}) do
      table.insert(scale,v+12*i)
    end
  end
  print("scale")
  tab.print(scale)

  clock.run(function()
    while true do 
      redraw()
      clock.sleep(1)
    end
  end)

  print("scramble")
  tab.print(choose(scramble({{4,5},{1,2,3}})))
  
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
      print("spaces")
      tab.print(spaces)
      -- root note
      table.insert(spaces,1,math.random(1,8))
      print("spaces")
      tab.print(spaces)
      for i,v in ipairs(spaces) do
        if i>1 then
          spaces[i]=spaces[i]+spaces[i-1]
        else
          -- play root note
          engine.bbjp2(timeScale,scale[spaces[i]]%12+24)
        end
        -- play other notes
        local note=scale[spaces[i]]+48
        print("note",note)
        engine.bbsine(timeScale,note)
      end
      clock.sleep(sleeptime)
      engine.bboff()
    end
  end)
end

-- search for these spaces
-- 2322 4321 2232 0453
-- 0342 6234 0453 1432
-- 4223 3321 7223 6322
-- 5342 0232 7324 7232
function redraw()
  screen.clear()
  screen.move(64,32)
  -- screen.text_center("hello, world")
  screen.text_center(string.format("%d-%d-%d-%d",seeds[1],seeds[2],seeds[3],seeds[4]))
  screen.update()
end
