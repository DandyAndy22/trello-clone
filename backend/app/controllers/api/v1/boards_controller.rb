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

    private

    def board_params
        params.require(:board).permit(:title)
    end
end
