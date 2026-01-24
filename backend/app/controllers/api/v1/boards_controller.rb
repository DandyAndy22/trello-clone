class Api::V1::BoardsController < ApplicationController
    def index
        boards = current_user.boards.order(:created_at)
        render json: boards
    end

    def create
        board = current_user.boards.build(board_params)
        if board.save
            render json: board, status: :created
        else
            render json: { errors: board.errors }, status: :unprocessable_entity
        end
    end

    def show
        board = current_user.boards.includes(lists: :cards).find(params[:id])
        render json: board.as_json(include: { lists: { include: :cards } })
    rescue ActiveRecord::RecordNotFound
        render json: { error: 'Board not found' }, status: :not_found
    end

    private

    def board_params
        params.require(:board).permit(:title)
    end
end
