class Api::V1::ListsController < ApplicationController
    def index
        lists = List.where(board_id: params[:board_id]).order(:position)
        render json: lists
    end

    def create
        list = List.new(list_params)
        list.board_id = params[:board_id]
        list.position = List.where(board_id: params[:board_id]).count

        if list.save
            render json: list, status: :created
        else
            render json: { error: list.errors }, status: unprocessable_entity
        end
    end

    private

    def list_params
        params.require(:list).permit(:title)
    end
end
