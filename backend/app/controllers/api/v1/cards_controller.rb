class Api::V1::CardsController < ApplicationController
    def index
        cards = Card.where(list_id: params[:list_id]).order(:position)
        render json: cards
    end

    def create
        list = List.find(params[:list_id])
        card = list.cards.build(card_params)
        card.position = list.cards.count

        if card.save
            render json: card, status: :created
        else
            render json: { errors: card.errors }, status: :unprocessable_entity
        end
    end

    def update
        card = Card.find(params[:id])

        if card.update(card_update_params)
            render json: card
        else
            render json: { errors: card.errors }, status: :unprocessable_entity
        end
    end

    private

    def card_update_params
        params.require(:card).permit(:title, :description, :position, :list_id)
    end

    def card_params
        params.require(:card).permit(:title, :description)
    end
end
