require 'set'


class Room
  attr_accessor :number, :hazards, :neighbors
  def initialize(number)
    @number = number
    @hazards = []
    @neighbors = []
  end

#hazards
  def empty?
    return hazards.empty?
  end

  def has?(hazard)
    hazards.include? hazard
  end

  def add(hazard)

    if not(has?(hazard))
      hazards.push(hazard)
    end

  end

  def remove(hazard)
    hazards.delete(hazard)
  end
#hazards
#Other Rooms
  def connect(room)

    #avoid infinite loop
    if neighbors.include? room
      return
    else
      neighbors.push(room)
      room.connect(self)
    end
  end

  def neighbor(number)

    neighbors.each do |obj|
      return obj if obj.number == number
    end

    return nil
  end

  def exits
    return neighbors.map {|x| x.number}
  end

  def random_neighbor
    return neighbors.sample
  end

  def safe?

    if not(self.empty?)
      return false
    end

    neighbors.each do |x|
      if not(x.empty?)
        return false
      end
    end

    return true
  end

#Other Room
end

class Cave
  private_class_method :new, :initialize
  attr_accessor :rooms

  def initialize
    @rooms = []
  end


  def Cave.dodecahedron

    cave = new

    cave.rooms = *(1..20)

    cave.rooms.each do |room|
      cave.rooms[room-1] = Room.new(room)
    end

    cave.rooms[0].connect(cave.rooms[1])
    cave.rooms[0].connect(cave.rooms[4])
    cave.rooms[0].connect(cave.rooms[7])

    #room 0 connected
    cave.rooms[1].connect(cave.rooms[2])
    cave.rooms[1].connect(cave.rooms[9])

    #room 1 conected
    cave.rooms[2].connect(cave.rooms[3])
    cave.rooms[2].connect(cave.rooms[11])

    #room 2 connected
    cave.rooms[3].connect(cave.rooms[4])
    cave.rooms[3].connect(cave.rooms[13])

    #room 0 connected
    #room 3 connected
    cave.rooms[4].connect(cave.rooms[5])

    #room 4 connected
    cave.rooms[5].connect(cave.rooms[6])
    cave.rooms[5].connect(cave.rooms[14])

    #room 5 already connected
    cave.rooms[6].connect(cave.rooms[7])
    cave.rooms[6].connect(cave.rooms[16])

    #room 0 connected
    #room 6 connected
    cave.rooms[7].connect(cave.rooms[10])

    cave.rooms[8].connect(cave.rooms[9])
    cave.rooms[8].connect(cave.rooms[11])
    cave.rooms[8].connect(cave.rooms[18])

    #room 1 connected
    #room 8 connected
    cave.rooms[9].connect(cave.rooms[10])

    #room 7 connected
    #room 9 connected
    cave.rooms[10].connect(cave.rooms[19])

    #room 2 connected
    #room 8 connected
    cave.rooms[11].connect(cave.rooms[12])

    #room 11 connected
    cave.rooms[12].connect(cave.rooms[13])
    cave.rooms[12].connect(cave.rooms[17])

    #room 3 connected
    #room 12 connected
    cave.rooms[13].connect(cave.rooms[14])

    #room 5 connected
    #room 13 connected
    cave.rooms[14].connect(cave.rooms[15])

    #room 14 connected
    cave.rooms[15].connect(cave.rooms[16])
    cave.rooms[15].connect(cave.rooms[17])

    #room 6 connected
    #room 15 connected
    cave.rooms[16].connect(cave.rooms[19])

    #room 12 connected
    #room 15 connected
    cave.rooms[17].connect(cave.rooms[18])

    #room 8 connected
    #room 17 connected
    cave.rooms[18].connect(cave.rooms[19])
    #room 19 should have its 3 connections

    return cave
  end


  def room(number)
    rooms.each do |obj|
      return obj if obj.number == number
    end
  end

  def random_room
    return rooms.sample
  end

  def move(hazard, params = {})
    params.fetch(:from).add(params.fetch(:to).remove(hazard))
  end

  def add_hazard(hazard, n)

    while n > 0

      rdm_room = random_room
      if not(rdm_room.has?(hazard))
        rdm_room.add(hazard)
        n-=1;
      end

    end

  end

  def room_with(hazard)
    rooms.each do |x|
      if x.has?(hazard)
        return x
      end
    end
  end

  def entrance
    rooms.each do |x|
      if x.safe?
        return x
      end
    end
  end

end

class Player

  attr_accessor :room

  def initialize
    @room = nil
    #hashes
    @sense_cd = {}
    @action_cb = {}
    @encounter_cb = {}
  end

  def enter(location)
    @room = location

    return if @room.empty?
    arr = [:bats, :guard, :pit, :wall]

    arr.each do |x|
      if @room.has?(x)
        @encounter_cb[x].call
      end
    end
  end

  def explore_room
    arr = [:bats, :guard, :pit, :wall]
    @room.neighbors.each do |x|
      arr.each do |y|
        if x.has?(y)
          @sense_cd[y].call
        end
      end
    end
  end

  def act(act, params)
    @action_cb[act].call(params)
  end
#callback
  def sense(hazard, &callback)
    @sense_cd[hazard] = callback;
  end

#callback
  def action(a, &callback)
    @action_cb[a] = callback
  end

#callback
  def encounter(hazard, &callback)
    @encounter_cb[hazard] = callback
  end

end


#############################TEST##############################################
#
# cave = Cave.dodecahedron
#
# cave.add_hazard(:guard, 1)
# cave.add_hazard(:pit, 3)
# cave.add_hazard(:bats, 3)
#
# player = Player.new
# narrator = Narrator.new
#
# player.sense(:bats) {
#  narrator.say("You hear a rustling")
# }
# player.sense(:guard) {
#  narrator.say("You smell something terrible")
# }
# player.sense(:pit) {
#  narrator.say("You feel a cold wind blowing")
# }
#
# #HOW THIS WORK?
# player.encounter(:guard) {
#  player.act(:startle_guard, player.room)
# }
#
# player.encounter(:bats) {
#  narrator.say "Giant bats whisk you away to a new cavern"
#
#  old_room = player.room
#  new_room = cave.random_room
#  player.enter(new_room)
#  cave.move(:bats, old_room, new_room)
# }
#
# player.encounter(:pit) {
#  narrator.finish_story "You fell into a bottomless pit"
# }
#
# player.action(:shoot) { |destination|
#  if destination.has?(:guard)
#  narrator.finish_story "You killed the guard! Good job"
#  else
# narrator.say "Your arrow missed"
#  player.act(:startle_guard, cave.room_with(:guard))
#  end
# }
#
# player.action(:startle_guard) { |old_guard_room|
#  if [:move, :stay].sample == :move # randomly select action
#  new_guard_room = old_guard_room.random_neighbor
# cave.move(:guard, old_guard_room, new_guard_room)
#  end
#
#  if player.room.has?(:guard)
#  narrator.finish_story "You woke up the guard and he killed you"
#  end
# }
