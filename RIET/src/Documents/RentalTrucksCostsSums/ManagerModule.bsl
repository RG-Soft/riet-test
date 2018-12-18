
Функция НастроитьДляВыбораИзRentalTracking(ServiceProvider, ДатаНачала, ДатаОкончания) Экспорт 
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("ServiceProvider", ServiceProvider);
	Запрос.УстановитьПараметр("Дата1", ДатаНачала);
	Запрос.УстановитьПараметр("Дата2", ДатаОкончания);
	Запрос.УстановитьПараметр("TypeOfTransport", Перечисления.TypesOfTransport.Rental);
	Запрос.УстановитьПараметр("Type", Перечисления.StopsTypes.Destination);
	Запрос.УстановитьПараметр("Stage", Перечисления.TripNonLawsonCompaniesStages.Closed);
	
	Запрос.Текст = 
	"ВЫБРАТЬ РАЗЛИЧНЫЕ
	|	TripNonLawsonCompaniesParcels.Ссылка КАК Trip
	|ИЗ
	|	Документ.TripNonLawsonCompanies.Parcels КАК TripNonLawsonCompaniesParcels
	|		ЛЕВОЕ СОЕДИНЕНИЕ Документ.TripNonLawsonCompanies.Stops КАК TripNonLawsonCompaniesStops
	|		ПО TripNonLawsonCompaniesParcels.Ссылка = TripNonLawsonCompaniesStops.Ссылка
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ РегистрСведений.StagesOfTripsNonLawsonCompanies КАК StagesOfTripsNonLawsonCompanies
	|		ПО TripNonLawsonCompaniesParcels.Ссылка = StagesOfTripsNonLawsonCompanies.Trip
	|ГДЕ
	|	TripNonLawsonCompaniesStops.ActualArrivalLocalTime МЕЖДУ &Дата1 И &Дата2
	|	И TripNonLawsonCompaniesParcels.Ссылка.Проведен
	|	И TripNonLawsonCompaniesParcels.Ссылка.TypeOfTransport = &TypeOfTransport
	|	И TripNonLawsonCompaniesParcels.Ссылка.ServiceProvider = &ServiceProvider
	|	И TripNonLawsonCompaniesStops.Type = &Type
	|	И StagesOfTripsNonLawsonCompanies.Stage = &Stage
	|
	|СГРУППИРОВАТЬ ПО
	|	TripNonLawsonCompaniesParcels.Ссылка
	|
	|УПОРЯДОЧИТЬ ПО
	|	TripNonLawsonCompaniesParcels.Ссылка.Дата";
	
	Возврат Запрос.Выполнить().Выгрузить();
			
КонецФункции
