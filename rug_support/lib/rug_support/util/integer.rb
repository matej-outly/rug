# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Integer utility functions 
# *
# * Author: Matěj Outlý
# * Date  : 17. 8. 2017
# *
# *****************************************************************************

class Integer
	
	#
	# Compute percantage based on two float values
	#
	def self.percentage(value_1, value_2)
		if value_2
			if value_1.to_f >= value_2.to_f
				return 100
			else
				return ((value_1.to_f * 100.0) / value_2.to_f).to_i
			end
		else
			return 100
		end
	end

	#
	# Convert number to human representation
	#
	# Only Czech language supported.
	#
	def to_words(locale = :cs)
		return nil if locale != :cs	
	
		# Normalize number format
		number = self.to_s

		# Recognize minus
		minus = number[0]
		if minus == "-"
			minus = "mínus "
		else
			minus = ""
		end
		number = number.gsub("-", "")

		# Recognize zero
		if number == "0"
			return "nula"
		end

		# Split into equal parts of 3 digits
		number_array = number.reverse.chars.each_slice(3).map(&:join)
		if number_array.length > 3
			return nil # Only support range from -999999999 to 999999999
		end

		# Dictionaries
		dictionary_1 = [" ", "jedna", "dvě", "tři", "čtyři", "pět", "šest", "sedm", "osm", "devět"]
		dictionary_2 = [" ", "deset", "dvacet", "třicet", "čtyřicet", "padesát", "šedesát", "sedmdesát", "osmdesát", "devadesát"]
		dictionary_3 = [" ", "sto", "stě", "sta", "sta", "set", "set", "set", "set", "set"]
		dictionary_4 = ["tisíc", "tisíc", "tisíce", "tisíce", "tisíce", "tisíc", "tisíc", "tisíc", "tisíc", "tisíc"]
		dictionary_5 = ["milión", "milión", "milióny", "milióny", "milióny", "miliónů", "miliónů", "miliónů", "miliónů", "miliónů"]

		result = ""

		(0..(number_array.length-1)).reverse_each do |idx_1|

			number_tmp = number_array[idx_1].reverse.chars.each_slice(1).map(&:join)
			
			# Analyse 3-digit part
			result_tmp = ""
			(0..(number_tmp.length-1)).each do |idx_2|
				order = idx_2 + (3 - number_tmp.length)
				if order == 0
					result_tmp = result_tmp + " " + dictionary_1[number_tmp[idx_2].to_i] + " " + dictionary_3[number_tmp[idx_2].to_i]
				elsif order == 1
					result_tmp = result_tmp + " " + dictionary_2[number_tmp[idx_2].to_i]
				elsif order == 2
					result_tmp = result_tmp + " " + dictionary_1[number_tmp[idx_2].to_i]
					last_tmp = number_tmp[idx_2].to_i # Asi neni potreba
				end
			end
			last_tmp = number_array[idx_1][0].to_i
			
			# Just copy
			if idx_1 == 0
				result += result_tmp
			end
			
			# Add "thousands"
			if idx_1 == 1
				if (number_array[idx_1].reverse)[-2..-1].to_i > 9 && (number_array[idx_1].reverse)[-2..-1].to_i < 15
					last_tmp = 1
				end
				result += result_tmp + " " + dictionary_4[last_tmp]
			end

			# Add "milions"
			if idx_1 == 2
				if (number_array[idx_1].reverse)[-2..-1].to_i > 9 && (number_array[idx_1].reverse)[-2..-1].to_i < 15
					last_tmp = 9
				end
				result += result_tmp + " " + dictionary_5[last_tmp]
			end
		end

		# Remove multiple white spaces
		result = result.gsub(/\s+/, " ")

		# Correct output
		replacements = [ 
			["deset jedna", "jedenáct"], 
			["deset dvě", "dvanáct"],
			["deset tři", "třináct"],
			["deset čtyři", "čtrnáct"],
			["deset pět", "patnáct"],
			["deset šest", "šestnáct"],
			["deset sedm", "sedmnáct"],
			["deset osm", "osmnáct"],
			["deset devět", "devatenáct"]
		]
		replacements.each {|replacement| result.gsub!(replacement[0], replacement[1])}
		
		replacements = [ 
			["jedna sto", "jedno sto"], 
			["jedna tisíc", "jeden tisíc"],
			["dvě tisíce", "dva tisíce"],
			["jedna milión", "jeden milión"],
			["dvě milióny", "dva milión"],
			["milión tisíc", "milión"],
			["milióny tisíc", "milióny"],
			["miliónů tisíc", "miliónů"]
		]
		replacements.each {|replacement| result.gsub!(replacement[0], replacement[1])}

		return (minus + result).trim
	end

	ROMAN_NUMBERS = {
		1000 => "M",  
		 900 => "CM",  
		 500 => "D",  
		 400 => "CD",
		 100 => "C",  
		  90 => "XC",  
		  50 => "L",  
		  40 => "XL",  
		  10 => "X",  
		   9 => "IX",  
		   5 => "V",  
		   4 => "IV",  
		   1 => "I",  
	}

	#
	# Convert number to Roman format
	#
	def to_roman
		number = self
		result = ""
		ROMAN_NUMBERS.each do |value, letter|
			result << letter * (number / value)
			number = number % value
		end
		return result
	end

end