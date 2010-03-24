class CollData
  attr_accessor :coll, :params
  include FromHash
  fattr(:search_str) { params[:sSearch] }
  fattr(:sort_col_index) { params[:iSortCol_0].present? ? params[:iSortCol_0].to_i : nil }
  fattr(:sort_col_name) { keys[sort_col_index] }
  fattr(:sort_dir) { params[:sSortDir_0].to_sym }
  fattr(:search_terms) { search_str.split(" ").map { |x| x.strip }.select { |x| x.present? } }
  def initial?
    params[:sEcho].to_i == 1
  end
  fattr(:find_ops) do
    {:limit => params[:iDisplayLength].to_i, :skip => params[:iDisplayStart].to_i, :sort => sort_terms}
  end
  def search_field_hash(term)
    parts = term.split(':').map { |x| x.strip }
    if parts.size == 1
      return {'_allwords' => /#{term}/i}
    elsif parts.size == 2
      field, value = *parts
      {field => /#{value}/i}
    elsif parts.size == 3
      field, op, value = *parts
      {field => {"$#{op}" => value.to_f}}
    else
      raise "bad"
    end
  end
  def selector
    return {} unless search_str.present?
    search_terms.inject({}) do |h,term|
      h.merge(search_field_hash(term))
    end
  end
  def sort_terms
    return nil unless sort_col_name.present?
    [[sort_col_name,sort_dir]]
  end
  fattr(:rows) do
    coll.find(selector,find_ops).to_a
  end
  fattr(:unpaginated_count) do
    coll.find(selector,{}).count
  end
  fattr(:keys){ coll.keys }
  fattr(:data) do
    rows.map { |row| row.values_in_key_order(keys) }
  end
  fattr(:json_hash) do
    {:sEcho => params[:sEcho], :iTotalRecords => coll.find.count, :iTotalDisplayRecords => unpaginated_count, :aaData => data}
  end
  def save_settings!
    puts "------ss start---------"
    puts "Coll Class: #{coll.class}"
    return unless coll.respond_to?(:user_coll)
    return if initial?
    puts "Setting fil"
    u = coll.user_coll
    puts "new: #{u.new?}"
    u.filter_conditions = selector
    puts u.inspect
    raise 'foo' unless u.save
    puts u.inspect
    puts "-----------saved------------"
    UserCollection.all.each { |x| puts x.inspect }
    db.collection('user_collections').find.each { |x| puts x.inspect }
  end
  fattr(:json_str) do
    #puts json_hash.without_keys(:aaData).merge(:rows_size => json_hash[:aaData].size).inspect
    save_settings!
    json_hash.to_json
  end
end