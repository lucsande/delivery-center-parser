module HashHelper
  def remove_field_from_hash(hash, field_path)
    edited_hash = hash
    fields = field_path.split('.')

    if fields.size == 1
      edited_hash.delete(fields.first)
    else
      edited_hash = remove_nested_field_from_hash(edited_hash, field_path)
    end

    edited_hash
  end

  def remove_nested_field_from_hash(hash, field_path)
    fields = field_path.split('.')
    target_field = fields.pop
    nested_hash = hash
    accessed_fields = []

    fields.each_with_index do |current_field, index|
      accessed_fields.push(current_field)
      reached_last_level = index == fields.size - 1

      nested_hash[current_field].delete(target_field) if reached_last_level # delete target field
      nested_hash = nested_hash[current_field]

      hash = update_nested_field_from_hash(hash, accessed_fields, nested_hash)
    end

    hash
  end

  def update_nested_field_from_hash(hash, field_path, new_value)
    fields = field_path.split('.')
    last_field = fields.pop

    fields.inject(hash, :fetch)[last_field] = new_value # updates original hash reaching for the nested value
  end
end
