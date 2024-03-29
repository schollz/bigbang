-- bigbang

ggrid_=include("lib/ggrid")
musicutil=require("musicutil")
engine.name="BigBang"
seeds={1,1,1,1}
playing_notes = {}
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

reverb_settings_saved={}
reverb_settings={
  reverb=2,
  rev_eng_input=0,
  rev_return_level=0,
  rev_low_time=9,
  rev_mid_time=6,
}
function init()
  math.randomseed( os.time() )
  for k,v in pairs(reverb_settings) do
    reverb_settings_saved[k]=params:get(k)
    params:set(k,v)
  end
  params:set("reverb",2)
  params:set("rev_eng_input",-3)
  params:set("rev_return_level",0)
  params:set("rev_low_time",9)
  params:set("rev_mid_time",6)

  ticks=0
  key=10
  intervals={}
  spaces={}
  scale={}
  timeScale=12
  for i=0,10 do
    for _,v in ipairs({0,2,4,5,7,9,11}) do
      table.insert(scale,v+12*i)
    end
  end
  print("scale")
  tab.print(scale)
  g_ = ggrid_:new{scale=scale}

  clock.run(function()
    while true do
      redraw()
      clock.sleep(1)
    end
  end)

  print("scramble")
  tab.print(choose(scramble({{4,5},{1,2,3}})))
  params:set("clock_tempo",100)

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
      local timeScale_=timeScale
      -- if math.random(1,100)<20 then 
      --   timeScale_ = timeScale_ * math.random(100,150)/2
      -- end
      local sleeptime=timeScale_*math.random(105,115)/100
      spaces=scramble(choose({
        {4,3,2},
        {3,2,1},
        {2,2,3},
        {3,4,5},
      }))
      -- root note
      table.insert(spaces,1,math.random(0,7))

      if (math.random(1,100)<99) then 
        if j%16<4 then
          options={{4,2,2,3},{3,3,2,1},{7,2,2,3},{6,3,2,2}}
        elseif j%16<8 then
          options={{0,3,4,2},{6,2,3,4},{0,4,5,3},{1,4,3,2}}
        elseif j%16<12 then
          options={{5,3,4,2},{0,2,3,2},{7,3,2,4},{7,2,3,2}}
        elseif j%16<16 then
          options={{2,3,2,2},{4,3,2,1},{2,2,3,2},{0,4,5,3}}
        end
        options={
          {2,2,3,2},{7,3,2,4}, {4,2,2,3},{7,2,2,3},-- C F G C 
          {7,2,3,2},{6,3,2,2}, {7,2,2,3},{6,2,3,4},-- Am Em C G
          {6,3,2,2},{2,3,2,2}, {1,4,3,2},{6,2,3,4},-- Em Am Dm G
        }
        spaces=options[j%#options+1]
      end

      for i,v in ipairs(spaces) do 
        intervals[i]=v
      end
      for i,v in ipairs(spaces) do
        if i>1 then
          spaces[i]=spaces[i]+spaces[i-1]
          table.insert(playing_notes,scale[spaces[i]+1]%12)
          engine.bbsine(timeScale_,scale[spaces[i]+1]+36+key)
        else
          -- play root note
          playing_notes = {scale[spaces[i]+1]%12}
          -- engine.bbjp2(timeScale_,scale[spaces[i]+1]%12+24+key)
          local bnote = scale[spaces[i]+1]%12+24+key
          if bnote > 44 then
            bnote = bnote - 12
          end
          engine.bbjp2(timeScale_,scale[spaces[i]+1]%12+24+key)
        end
      end
      -- for _, v in ipairs(spaces) do 
      --   print(musicutil.note_num_to_name(scale[v+1]))
      -- end
      tick_count=util.round(sleeptime/0.1)
      ticks=tick_count
      for ii=1,ticks do 
        ticks = ticks - 1
        clock.sleep(0.1)
        redraw()
      end

      engine.bboff()
    end
  end)
end

function redraw()
  screen.clear()
  -- screen.font_size(8)
  -- screen.move(64,14)
  -- screen.text_center(string.format("%d-%d-%d-%d",intervals[1],intervals[2],intervals[3],intervals[4]))
  screen.font_size(16)
  screen.move(64,30)
  screen.text_center(string.format("%s %s %s %s",
    musicutil.note_num_to_name(scale[spaces[1]+1]),
    musicutil.note_num_to_name(scale[spaces[2]+1]),
    musicutil.note_num_to_name(scale[spaces[3]+1]),
  musicutil.note_num_to_name(scale[spaces[4]+1])))
  screen.move(64,50)
  screen.font_size(16)
  screen.text_center(string.format("%2.1f",ticks/10))
  screen.update()
end
