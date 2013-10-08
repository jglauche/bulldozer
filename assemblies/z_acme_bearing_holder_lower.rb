class ZAcmeBearingHolderLower < CrystalScad::Assembly
	
	def show
		part(true)
	end
	
	def output
		part
	end

	def part(show=false)
		# bearing holder needs to be moved to a separate part to have a good 
		# tool access to the motor mounting bolts
		res = cube([30,5,30]).color(@@printed_color)	

		res += cube([48,47,6]).color(@@printed_color)	
		bearing = Bearing.new(:type => "625", :margin_diameter => 0.2, :outer_rim_cut=>5, :no_bom => true)
	
		res -= bearing.output.translate(x:26,y:27,z:2)			
		#res += bearing.show.translate(x:26,y:27,z:2) if show	

		res -= long_slot(d:4.4,h:10,l:14).rotate(y:90,z:90).translate(x:15,y:-3,z:25)

		bolt = Bolt.new(4,12)
		washer = Washer.new(4.3)		
		res += bolt.show.rotate(x:90).translate(x:15,y:6,z:20) if show
		res += washer.show.rotate(x:90).translate(x:15,y:6,z:20) if show

	# endstop
		res += MicroswitchD3V.new.show.rotate(z:-90).translate(x:-10,y:40,z:10)

		
	end	

end
