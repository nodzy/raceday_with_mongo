  class Racer
    include ActiveModel::Model
    attr_accessor :id, :number, :first_name, :last_name, :gender, :group, :secs
    
    def initialize(params={})
      @id=params[:_id].nil? ? params[:id] : params[:_id].to_s
      @number=params[:number].to_i
      @first_name=params[:first_name]
      @last_name=params[:last_name]
      @gender=params[:gender]
      @group=params[:group]
      @secs=params[:secs].to_i
    end
    
    def self.mongo_client
     Mongoid::Clients.default
   end

   def self.collection
     self.mongo_client['racers']
   end
   
   
   def self.all(prototype={}, sort={:number=>1}, skip=0, limit=nil)

    result=collection.find(prototype).projection({_id:true, number:true, first_name:true, last_name:true, gender:true, group:true, secs:true}).sort(sort).skip(skip)

    result=result.limit(limit) if !limit.nil?

    return result



  end


  def self.find id
    result=collection.find(:_id=>BSON::ObjectId.from_string(id.to_s)).first
    return result.nil? ? nil : Racer.new(result)

  end


  def save
    result=self.class.collection.insert_one(:number => @number,
      :first_name => @first_name,
      :last_name => @last_name,
      :gender => @gender,
      :group => @group,
      :secs => @secs)

    
    @id=result.inserted_id.to_s
  end

  def update(params)
    @number=params[:number].to_i
    @first_name=params[:first_name]
    @last_name=params[:last_name]
    @secs=params[:secs].to_i
    @gender=params[:gender]
    @group=params[:group]

    params.slice!(:number, :first_name, :last_name, :gender, :group, :secs)
    self.class.collection
    .find(:_id=>BSON::ObjectId.from_string(id.to_s))
    .update_one(:$set => {number: @number, first_name: @first_name, last_name: @last_name, gender: @gender, secs: @secs, group: @group})

  end

  def destroy
    self.class.collection
    .find(:_id=>BSON::ObjectId.from_string(id.to_s))
    .delete_one
  end


  def persisted?
    !@id.nil?
  end

  def created_at
    nil
  end
  def updated_at
    nil
  end


  def self.paginate(params)
    page=(params[:page] || 1).to_i
    limit=(params[:per_page] || 30).to_i
    skip=(page-1)*limit

    racers=[]
    all({}, {}, skip, limit).each do |doc|
      racers << Racer.new(doc)
    end
    total=all.count

    WillPaginate::Collection.create(page, limit, total) do |pager|
      pager.replace(racers)
    end 


  end
end