-- local pattern_time = require("pattern")
local GGrid={}


function GGrid:new(args)
  local m=setmetatable({},{__index=GGrid})
  local args=args==nil and {} or args

  m.scale = args.scale
  m.grid_on=args.grid_on==nil and true or args.grid_on

  -- initiate the grid
  m.g=grid.connect()
  m.g.key=function(x,y,z)
    if m.grid_on then
      m:grid_key(x,y,z)
    end
  end
  print("grid columns: "..m.g.cols)

  -- setup visual
  m.visual={}
  m.lightsout={}
  m.playing={}
  m.grid_width=16
  for i=1,8 do
    m.lightsout[i]={}
    m.playing[i]={}
    m.visual[i]={}
    for j=1,m.grid_width do
      m.visual[i][j]=0
      m.lightsout[i][j]=0
      m.playing[i][j]=0
    end
  end

  m.notes={}
  for row=1,8 do 
    table.insert(m.notes,{})
    for col=1,16 do 
        table.insert(m.notes[row],0)
    end
  end
  local istart = 1
  for col=1,16 do 
    local i = istart
    for row=8,1,-1 do 
        m.notes[row][col] = m.scale[i]
        i = i + 1
    end
    istart = istart + 4    
  end

  -- keep track of pressed buttons
  m.pressed_buttons={}

  -- keep track of active notes by position
  m.active_notes={}

  -- grid refreshing
  m.grid_refresh=metro.init()
  m.grid_refresh.time=0.1
  m.grid_refresh.event=function()
    if m.grid_on then
      m:grid_redraw()
    end
  end
  m.grid_refresh:start()


  crow.output[2].action=string.format("adsr(1,2,5,1)")

  return m
end


function GGrid:grid_key(x,y,z)
  self:key_press(y,x,z==1)
  self:grid_redraw()
end

function GGrid:key_press(row,col,on)
  local pos_key = row..","..col
  local note = self.notes[row][col]+key

  if on then
    -- Button pressed - start note
    self.pressed_buttons[pos_key]=clock.get_beats()
    self.active_notes[pos_key]=note
    print("note on:", row, col, note)

    -- Play the note
    engine.bbsine(12, note)

    -- Update crow for most recent note
    local volts = (note-24)/12
    crow.output[1].volts=volts
    crow.output[2](true)
  else
    -- Button released - stop note
    self.pressed_buttons[pos_key]=nil

    if self.active_notes[pos_key] then
      print("note off:", row, col, self.active_notes[pos_key])
      -- Turn off this specific note
      engine.bboff_note(self.active_notes[pos_key])
      self.active_notes[pos_key]=nil
    end

    -- If no notes are playing, release crow gate
    if next(self.pressed_buttons)==nil then
      crow.output[2](false)
      engine.bboff()
    end
  end
end


function GGrid:get_visual()
  -- clear visual
  for row=1,8 do
    for col=1,self.grid_width do
      if self.visual[row][col]>5 then 
        self.visual[row][col]=self.visual[row][col]-1
      else
        self.visual[row][col]=0
      end
    end
  end

  -- illuminate playing notes
  for row=1,8 do 
    for col=1,16 do 
        for _, v in ipairs(playing_notes) do 
            if self.notes[row][col]~=nil then 
                local vv=self.notes[row][col]%12
                if vv==0 then 
                    self.visual[row][col]=1
                end
                if vv==v then 
                    self.visual[row][col]=4
                end
            end
        end      
    end
  end
  -- illuminate currently pressed button
  for k,_ in pairs(self.pressed_buttons) do
    local row,col=k:match("(%d+),(%d+)")
    self.visual[tonumber(row)][tonumber(col)]=15
  end

  return self.visual
end


function GGrid:grid_redraw()
  self.g:all(0)
  local gd=self:get_visual()
  local s=1
  local e=self.grid_width
  local adj=0
  for row=1,8 do
    for col=s,e do
      if gd[row][col]~=0 then
        self.g:led(col+adj,row,gd[row][col])
      end
    end
  end
  self.g:refresh()
end

return GGrid
