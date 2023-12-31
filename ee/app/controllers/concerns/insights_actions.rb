# frozen_string_literal: true

module InsightsActions
  extend ActiveSupport::Concern

  included do
    before_action :check_insights_available!
    before_action :validate_params, only: [:query]

    rescue_from Gitlab::Insights::Validators::ParamsValidator::ParamsValidatorError,
      Gitlab::Insights::Finders::IssuableFinder::IssuableFinderError,
      Gitlab::Insights::Reducers::BaseReducer::BaseReducerError, with: :render_insights_chart_error
  end

  def show
    respond_to do |format|
      format.html
      format.json do
        render json: config_data
      end
    end
  end

  def query
    respond_to do |format|
      format.json do
        render json: insights_json
      end
    end
  end

  private

  def check_insights_available!
    render_404 unless insights_entity.insights_available?
  end

  def validate_params
    Gitlab::Insights::Validators::ParamsValidator.new(params).validate!
  end

  def chart_type_param
    @chart_type_param ||= params[:chart_type]
  end

  def query_param
    @query_param ||= params[:query]
  end

  def period_param
    @period_param ||= query_param[:group_by]
  end

  def collection_labels_param
    @collection_labels_param ||= query_param[:collection_labels]
  end

  def insights_json
    issuables = finder.find
    insights = reduce(issuables: issuables, period_limit: finder.period_limit)
    serializer.present(insights)
  end

  def reduce(issuables:, period_limit: nil)
    case chart_type_param
    when 'stacked-bar', 'line'
      Gitlab::Insights::Reducers::LabelCountPerPeriodReducer.reduce(issuables, period: period_param, period_limit: period_limit, labels: collection_labels_param)
    when 'bar', 'pie'
      if period_param
        Gitlab::Insights::Reducers::CountPerPeriodReducer.reduce(issuables, period: period_param, period_limit: period_limit)
      else
        Gitlab::Insights::Reducers::CountPerLabelReducer.reduce(issuables, labels: collection_labels_param)
      end
    end
  end

  def finder
    @finder ||=
      Gitlab::Insights::Finders::IssuableFinder
        .new(insights_entity, current_user, query_param)
  end

  def serializer
    case chart_type_param
    when 'stacked-bar'
      Gitlab::Insights::Serializers::Chartjs::MultiSeriesSerializer
    when 'bar', 'pie'
      if period_param
        Gitlab::Insights::Serializers::Chartjs::BarTimeSeriesSerializer
      else
        Gitlab::Insights::Serializers::Chartjs::BarSerializer
      end
    when 'line'
      Gitlab::Insights::Serializers::Chartjs::LineSerializer
    end
  end

  def config_data
    insights_entity.insights_config
  end

  def render_insights_chart_error(exception)
    render json: { message: exception.message }, status: :unprocessable_entity
  end
end
