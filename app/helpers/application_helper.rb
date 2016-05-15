module ApplicationHelper
	def sortable(column, title = nil)
	  	title ||= column.titleize
	  	css_class = column == sort_column ? "sort-column js_column current #{sort_direction}" : "sort-column js_column"
	  	direction = column == sort_column && sort_direction == "asc" ? "desc" : "asc"
	  	#link_to title, params.merge(:sort => column, :direction => direction, :page => nil), {:class => css_class}
	  	link_to title, "javascript:void(0)", {:class => css_class,:sort => column, :direction => direction}
	end

	def check_visibility?(permission)
		if (!current_admin.permissions.nil?) && (current_admin.permissions.include? permission)
			return true
		else
			return false
		end
	end
end