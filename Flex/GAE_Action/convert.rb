require "find"

#使っている文字を（１６進数として）記録する
h = Hash::new

Find.find('./'){|file_name|
	if /as$/ =~ file_name
		#使う文字の入ったテキストファイルを開く
		src = open(file_name)

		#バイナリモードにする
		src.binmode

		src.read.unpack('U*').each{|val|
			num = val.to_s(16)

			while num.length < 4
				num = '0' + num;
			end

			num = num.upcase

			h['U+'+num] = 1
		}

		src.close
	end
}

#使っている文字をプリントアウト
text_out = open("MyFont.as", "w")

text_out.puts "package{"
	text_out.puts "\tpublic class MyFont{"
		text_out.puts "\t\t[Embed("
			text_out.puts "\t\t\tsource='mplus-1m-medium.ttf',"
			text_out.puts "\t\t\tfontName='system',"
			text_out.print "\t\t\tunicodeRange='"
			h.each_key {|key| text_out.print key + ","}
			text_out.puts "'"
		text_out.puts "\t\t)]"
		text_out.puts "\t\tprivate var GameFont:Class"
	text_out.puts "\t}"
text_out.puts "}"

text_out.close

