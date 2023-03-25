class UsersController < ApplicationController
  before_action :authenticate_user!

  def show
    @user = User.find(params[:id])
#    @students = User.where(role: 'student').order('updated_at desc') if @user.role == 'teacher'
    @posts = Post.where(user_id: @user.id).order('created_at desc')
    @posts = Kaminari.paginate_array(@posts).page(params[:page])

    visit = current_user.visits.find_by(visitee: @user.id)
    if (visit != nil)
      visit.touch
    else
      current_user.visits << Visit.create(visitee: @user.id)
    end

    if @user.role == 'teacher'
      @students = User.where(role: 'student').order('updated_at desc')
      @updated_users = []
      current_user.visits.each {|v|
        st = @students.find_by(id: v.visitee)
        next if st == nil
        @updated_users.push(st.id) if (Post.where(user_id: v.visitee).where(updated_at: v.updated_at ... Time.now).size > 0)
      }
    end      
  end
end
