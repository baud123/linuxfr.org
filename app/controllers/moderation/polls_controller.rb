class Moderation::PollsController < ModerationController
  before_filter :find_poll, :except => [:index]

  def index
    @polls = Poll.draft
  end

  def show
    enforce_view_permission(@poll)
  end

  def accept
    enforce_accept_permission(@poll)
    @poll.accept!
    redirect_to @poll, :notice => "Sondage accepté"
  end

  def refuse
    enforce_refuse_permission(@poll)
    @poll.refuse!
    redirect_to moderation_polls_url, :notice => "Sondage refusé"
  end

  def edit
    enforce_update_permission(@poll)
  end

  def update
    enforce_update_permission(@poll)
    @poll.attributes = params[:poll]
    if @poll.save
      redirect_to [:moderation, @poll], :notice => "Modification enregistrée"
    else
      flash.now[:alert] = "Impossible d'enregistrer ce sondage"
      render :edit
    end
  end

protected

  def find_poll
    @poll = Poll.find(params[:id])
  end

end
