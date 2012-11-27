module TableCloth
  module Presenters
    class Default < ::TableCloth::Presenter
      def render_table
        wrapper_tag :table do
          render_header + render_rows
        end
      end

      def render_rows
        wrapper_tag :tbody do
          v.raw objects.inject('') {|r, object| r + render_row(object) }
        end
      end

      def render_row(object)
        wrapper_tag :tr do
          v.raw table.columns.inject('') {|tds, (key, column)| tds + render_td(column, object) }
        end
      end

      def render_td(column, object)
        td_options = column.options.delete(:td_options) || {}
        value = column.value(object, view_context, table) rescue ''

        if value.is_a?(Array)
          options = value.pop
          value   = value.shift

          td_options.update(options)
        end

        wrapper_tag(:td, value, td_options)
      end

      def render_header
        wrapper_tag :thead do
          wrapper_tag :tr do
            v.raw column_names.inject('') {|tags, name| tags + wrapper_tag(:th, name) }
          end
        end
      end
    end
  end
end

module TableCloth
  module Presenters
    class Default
      def render_row_with_secondary(object)
        # if there is a secondary, then display first combined row + other secondary-only rows
        if table.secondary && !(secondary_array = object.send(table.secondary)).empty?
          value = wrapper_tag :tr do
            v.raw table.columns.inject('') {|tds, (key, column)| tds + render_td(column, object.respond_to?(column.name) ? object : secondary_array.first) }
          end
          ([value] + secondary_array[1..-1]).collect{|row| render_row_without_secondary(row)}.join('')
        else
          render_row_without_secondary(object)
        end
      end
      alias_method_chain :render_row, :secondary

    end
  end
end

