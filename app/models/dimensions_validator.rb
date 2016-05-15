class DimensionsValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    # I'm not sure about this:
    dimensions = Paperclip::Geometry.from_file(value.queued_for_write[:original].path)
    # But this is what you need to know:
    #width = options[:width]
    #height = options[:height] 

    record.errors[attribute] << "Width:Height ratio must be 2:1" unless dimensions.width == (2*dimensions.height)
    #record.errors[attribute] << "Height must be #{height}px" unless dimensions.height == height
  end
end