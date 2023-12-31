# frozen_string_literal: true

module LicenseManagementReportHelper
  def create_report(dependencies)
    Gitlab::Ci::Reports::LicenseManagement::Report.new.tap do |report|
      dependencies.each do |license_name, dependencies|
        dependencies.each do |dependency_name|
          report.add_dependency(license_name.to_s, dependency_name)
        end
      end
    end
  end

  def create_report1
    create_report(
      License1: %w(Dependency1 Dependency2),
      License2: %w(Dependency1),
      License3: %w(Dependency3)
    )
  end

  def create_report2
    create_report(
      License2: %w(Dependency1),
      License3: %w(Dependency3),
      License4: %w(Dependency4 Dependency1)
    )
  end

  def create_comparer
    Gitlab::Ci::Reports::LicenseManagement::ReportsComparer.new(create_report1, create_report2)
  end

  def create_license
    Gitlab::Ci::Reports::LicenseManagement::License.new('License1').tap do |license|
      license.add_dependency('Dependency1')
      license.add_dependency('Dependency2')
    end
  end

  def create_dependency
    Gitlab::Ci::Reports::LicenseManagement::Dependency.new('Dependency1')
  end
end
