class Api::V1::CardsController < ApplicationController
    def index
        cards = Card.where(list_id: params[:list_id]).order(:position)
        render json: cards
    end

    def create
        card = Card.new(card_params)
        card.list_id = params[:list_id]
        card.position = Card.where(list_id: params[:list_id]).count

        if card.save
            render json: card, status: :created
        else
            render json: { errors: card.errors }, status: :unprocessable_entity
        end
    end

    private

    def card_params
        params.require(:card).permit(:title, :description)
    end
end
