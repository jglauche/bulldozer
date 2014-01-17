class BulldozerFrameAssembly < CrystalScad::Assembly

	def initialize
	  # tslot variable being the basic printer dimensions
		@tslot_x = 295	
		@tslot_y = 495
		@tslot_z = 453 
		
		@frame_x = 600			
		@frame_y = @tslot_y+60		

		@main_position = {x:240,y:30,z:360}
	  @z_tslot_position = 355 
	  @y_plate_inner_length = @tslot_y - 65
	
	  @bulldozer_position = 0
	  @y_plate_position = 0
		@tslot_single = TSlot.new(size:30,configuration:1,simple:@tslot_simple)
		@tslot_double = TSlot.new(size:30,configuration:2,simple:@tslot_simple)

		@show_side_plates = true
		@door_rotation = 135
	end
	
	def show
		res = part
		res+= ZAxisAssembly.new(tslot_simple:false,position:@z_tslot_position).show.translate(@main_position)
	
		res += YPlateAssembly.new(length:@y_plate_inner_length,rod_size:12,position:-20+@y_plate_position).show.translate(@main_position).translate(z:3.5,y:30,x:35)
		res += XAxisAssembly.new(position:15+200).show.translate(@main_position).translate(z:100+0,y:@z_tslot_position,x:-2.5).translate(z:30)

		res += BulldozerAssembly.new(position:5+@bulldozer_position).show.translate(@main_position)
		res += BulldozerRodHolder.new.show(:right).translate(@main_position).translate(x:330,y:-7,z:-75)
		res += BulldozerRodHolder.new.show(:left).translate(@main_position).translate(x:-35,y:-7,z:-75)


		# bottom sheet		
		res += AluminiumCompositeSheet.new(x:@frame_x,y:@frame_y).show.translate(z:30)
		if @show_side_plates
			# top sheet
			res += AluminiumCompositeSheet.new(bolt_size:8,with_nut:false,x:@frame_x+60,y:@frame_y).show.translate(x:-30,z:@frame_z+30)

			# back wall 
			# FIXME: this needs to be either split or cut more to have a cutout for the power and network connector
			res += AluminiumCompositeSheet.new(x:@frame_x+60,y:@frame_z+30).show.mirror(z:1).rotate(x:90).translate(x:-30,y:@frame_y)
		
			# left wall
			res += AluminiumCompositeSheet.new(x:@frame_y-60,y:@frame_z+30).show.rotate(x:90,z:90).mirror(x:1).translate(y:30)
			# right wall
			res += AluminiumCompositeSheet.new(x:@frame_y-60,y:@frame_z+30).show.rotate(x:90,z:90).translate(x:@frame_x,y:30)
		end

			# bottom doors
			res += Door.new(sheet:DoorSheet.new(x:@frame_x/2-1,y:@container_z-1),rotation:@door_rotation,z_offset:10).show.translate(x:-0,y:-10,z:30+0.5)
			res += Door.new(sheet:DoorSheet.new(x:@frame_x/2-1,y:@container_z-1),rotation:@door_rotation,z_offset:10).show.mirror(x:1).translate(x:@frame_x,y:-10,z:30+0.5)

			# upper doors
			res += Door.new(sheet:DoorSheet.new(x:@frame_x/2-1,y:@frame_z-@container_z-60-1),rotation:@door_rotation,z_offset:10).show.translate(x:-0,y:-10,z:@container_z+60+0.5)
			res += Door.new(sheet:DoorSheet.new(x:@frame_x/2-1,y:@frame_z-@container_z-60-1),rotation:@door_rotation,z_offset:10).show.mirror(x:1).translate(x:@frame_x,y:-10,z:@container_z+60+0.5)
	

		# FIXME: we need a new place for electronics
		
		# FIXME: where to put spool and how will spool mounting look like?
		spool = Spool300mm.new
		#res += spool.rotate(y:90).translate(x:33,y:250,z:700)
		res
	end

	def output
		part	
	end

	def part
		container = Container.new
		container2 = Container.new

		res = main_rect.translate(z:z=0)
		# slot where the printer stands on	
		@container_z = container.z+15
		res += printer_stage_rect.translate(z:z+=@container_z+60)
	

		res += main_rect.translate(z:z+=540+10)
		
		@frame_z = z


		# lower base tslot
		res += tslot_rectangle(@tslot_x,@tslot_y, @tslot_double,@tslot_double).translate(@main_position) 
		res += rubber_dampener.translate(@main_position) 
	
		# upper tslot
		res += @tslot_single.show(@frame_y-60).rotate(y:90,z:90).translate(x:220-13,y:30,z:@frame_z+30)
	
		
		# left container: part container
		# right container: waste container
		res += container.show.translate(x:20,y:20,z:33)
		res += container2.show.translate(x:20+280,y:20,z:33)

		res += tslot_sides

		res
	end
	
	def main_rect
		tslot_rectangle(@frame_x,@frame_y, @tslot_single,@tslot_single).translate(z:30)	
	end

	def printer_stage_rect
		x,y = @frame_x,@frame_y
		size=30
		r = @tslot_double.show(x-size*2).rotate(x:-90,z:-90).rotate(x:90).translate(x:size,y:0)
		r += @tslot_double.show(x-size*2).rotate(x:-90,z:-90).rotate(x:90).translate(x:size,y:y-size*2)   

		# y
		r += @tslot_single.show(y).rotate(x:-90)
		r += @tslot_single.show(y).rotate(x:-90).mirror(x:1).translate(x:x)
		
	end

	def rubber_dampener
		res = CrystalScadObject.new
		[[0,0],[265,0],[0,@tslot_y-30+14],[265,@tslot_y-30+14]].each do |x,y|
			r= RubberDampener.new
			t = TSlotNut.new
			assembly += r.show
			assembly += t.show.mirror(z:1).translate(r.threads_top.position_on(t.threads_top)).translate(z:18)
			res += assembly.translate(x:15+x,y:8+y,z:-71)		
		end
		res	
	end

	def tslot_sides


		# right
		res += @tslot_single.show(@frame_z+30).rotate(z:90)
		res += @tslot_single.show(@frame_z+30).rotate(z:90).translate(y:@frame_y-30)

		# left 
		res += @tslot_single.show(@frame_z+30).rotate(z:90).translate(x:@frame_x+30)
		res += @tslot_single.show(@frame_z+30).rotate(z:90).translate(x:@frame_x+30,y:@frame_y-30)


		res.color("Silver")
	end
	

	def tslot_rectangle(x,y,tslot_type_x,tslot_type_y)
		size = tslot_type_x.args[:size]
		# x 
		r = tslot_type_x.show(x-size*2).rotate(x:-90,z:-90).translate(x:size,y:size)
		r += tslot_type_x.show(x-size*2).rotate(x:-90,z:-90).translate(x:size,y:y)   

		# y
		r += tslot_type_y.show(y).rotate(x:-90)
		r += tslot_type_y.show(y).rotate(x:-90).mirror(x:1).translate(x:x)
		
	end



end
