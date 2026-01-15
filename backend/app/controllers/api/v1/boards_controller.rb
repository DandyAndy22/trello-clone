class Api::V1::BoardsController < ApplicationController
    def index
        boards = Board.all
        render json: boards
    end

    def create
        board = Board.new(board_params)
        if board.save
            render json: board, status: :created
        else
            render json: { errors: board.errors }, status: :unprocessable_entity
        end
    end

    def show
        board = Board.includes(:lists).find(params[:id])
        render json: board.as_json(include: :lists)
    rescue ActiveRecord::RecordNotFound
        render json: { error: 'Board not found' }, status: :not_found
    end

    private

    def board_params
        params.require(:board).permit(:title)
    end
end
