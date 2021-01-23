note
	description: "Summary description for {JSON_FILE}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	JSON_FILE

create
	make

create
	make_from_json

create
	make_from_list

feature -- Initialization

	name: STRING
	header: ARRAYED_LIST [STRING]
	types: ARRAYED_LIST [STRING]
	body: ARRAYED_LIST [JSON_OBJECT]

	make

		do
			create name.make_empty
			create header.make (0)
			create types.make (0)
			create body.make (0)
		end

	make_from_json (i_name: STRING; i_header: ARRAYED_LIST [STRING]; i_types: ARRAYED_LIST [STRING]; i_body: ARRAYED_LIST [JSON_OBJECT])

		do
			create name.make_from_string (i_name)
			create header.make_from_iterable (i_header)
			create types.make_from_iterable (i_types)
			create body.make_from_iterable (i_body)
		end

	make_from_list (i_name: STRING; i_header: ARRAYED_LIST [STRING]; i_types: ARRAYED_LIST [STRING]; i_body: ARRAYED_LIST [ARRAYED_LIST [STRING]])

		local
			i: INTEGER
			max: INTEGER
			json: JSON_OBJECT

		do
			create name.make_from_string (i_name)
			create header.make_from_iterable (i_header)
			create types.make_from_iterable (i_types)
			create body.make (0)

			across i_body as line
			loop
				create json.make_empty
				from
					i := 1
					max := line.item.count
				until
					i > max
				loop
					if line.item.at (i).is_equal ("") then
						json.put (Void, i_header.at (i))
					elseif i_types.at (i).is_equal ("X") then
						json.put_string (line.item.at (i), i_header.at (i))
					elseif i_types.at (i).is_equal ("N") then
						line.item.at (i).replace_substring_all (",", ".")
						json.put_real (line.item.at (i).to_real_64, i_header.at (i))
					elseif i_types.at (i).is_equal ("B") then
						if line.item.at (i).is_equal ("T") or line.item.at (i).is_equal ("S") then
							json.put_boolean (True, i_header.at (i))
						elseif line.item.at (i).is_equal ("F") or line.item.at (i).is_equal ("N") then
							json.put_boolean (False, i_header.at (i))
						end
					end
					i := i + 1
				end
				body.extend (json)
			end
		end

feature {NONE} -- Private

feature -- Public

	matching_lines (key: STRING; value_string: STRING) : ARRAYED_LIST [JSON_OBJECT]

		local
			matching_jsons: ARRAYED_LIST [JSON_OBJECT]

		do
			create matching_jsons.make (0)
			across body as line
			loop
				if attached line.item.item (key) as value then
					if value_string.same_string (value.representation) then
						matching_jsons.extend (line.item)
					end
				end
			end
			result := matching_jsons
		end

	to_string : STRING

		local
			json_string: STRING

		do
			create json_string.make_from_string (name + "%N")

			across header as key
			loop
				json_string.append (key.item + ", ")
			end
			json_string.remove_tail (2)
			json_string.append ("%N")

			across types as type
			loop
				json_string.append (type.item + ", ")
			end
			json_string.remove_tail (2)
			json_string.append ("%N")
			json_string.append (body_to_string)
			result := json_string
		end

	body_to_string : STRING

		local
			body_string: STRING

		do
			create body_string.make_from_string ("[%N")
			across body as line
			loop
				body_string.append ("{")
				across header as key
				loop
					if attached line.item.item (key.item) as value then
						body_string.append ("%"" + key.item + "%":" + value.representation + ", ")
					end
				end
				body_string.remove_tail (2)
				body_string.append ("},%N")
			end
			body_string.remove_tail (2)
			body_string.append ("%N]")
			result := body_string
		end

	to_csv_string : STRING

		local
			json_string: STRING
			value_string: STRING

		do
			create json_string.make_empty

			across header as head
			loop
				json_string.append (head.item + ";")
			end
			json_string.remove_tail (1)
			json_string.append ("%N")

			across types as type
			loop
				json_string.append (type.item + ";")
			end
			json_string.remove_tail (1)
			json_string.append ("%N")

			across body as line
				loop
					across header as key
					loop
						if attached line.item.item (key.item) as value then
							create value_string.make_from_string (value.representation)
							if attached {JSON_STRING} value then
								value_string.remove_head (1)
								value_string.remove_tail (1)
							end
							json_string.append (value_string + ";")
						end
					end
					json_string.remove_tail (1)
					json_string.append ("%N")
				end
			result := json_string
		end

end
