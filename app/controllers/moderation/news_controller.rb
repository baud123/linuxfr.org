class Moderation::NewsController < ModerationController
  before_filter :find_news, :except => [:index]

  def index
    @news  = News.candidate.sorted
    @polls = Poll.draft
  end

  def show
    enforce_view_permission(@news)
    @boards = @news.boards
    respond_to do |wants|
      wants.html {
        redirect_to [:moderation, @news], :status => 301 and return if @news.has_better_id?
        render :show, :layout => 'chat_n_edit'
      }
      wants.js { render :partial => 'short' }
    end
  end

  def edit
    enforce_update_permission(@news)
    respond_to do |wants|
      wants.js { render :partial => 'form' }
    end
  end

  def update
    enforce_update_permission(@news)
    @news.attributes = params[:news]
    @news.editor_id = current_user.id
    @news.save
    respond_to do |wants|
      wants.js { render :nothing => true }
    end
  end

  def accept
    enforce_accept_permission(@news)
    if @news.unlocked?
      @news.moderator_id = current_user.id
      @news.accept!
      NewsNotifications.accept(@news).deliver
      redirect_to @news, :alert => "Dépêche acceptée"
    else
      redirect_to [:moderation, @news], :alert => "Impossible de modérer la dépêche tant que quelqu'un est en train de la modifier"
    end
  end

  def refuse
    enforce_refuse_permission(@news)
    if params[:message]
      @news.refuse!
      notif = NewsNotifications.refuse_with_message(@news, params[:message], params[:template])
      notif.deliver if notif
      redirect_to @news
    elsif @news.unlocked?
      @boards = @news.boards
    else
      redirect_to [:moderation, @news], :alert => "Impossible de modérer la dépêche tant que quelqu'un est train de la modifier"
    end
  end

  def ppp
    enforce_ppp_permission(@news)
    @news.set_on_ppp
    redirect_to @news
  end

  # TODO to be removed?
  def show_diff
    enforce_view_permission(@news)
    @commit = Commit.new(@news, params[:sha])
  end

  def clear_locks
    enforce_update_permission(@news)
    @news.clear_locks(current_user)
    respond_to do |wants|
      wants.html { redirect_to :back }
      wants.js   { render :nothing => true }
    end
  end

protected

  def find_news
    @news = News.find(params[:id])
  end

end
