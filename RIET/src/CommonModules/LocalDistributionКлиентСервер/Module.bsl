// { RGS AGorlenko 22.04.2014 18:33:18 - S-I-0000686
//Функция ОбновитьTripFinalDestinations(TripFinalDestinations, МассивWarehouseTo) Экспорт
Функция ОбновитьTripFinalDestinations(TripFinalDestinations, МассивParcels) Экспорт
// } RGS AGorlenko 22.04.2014 18:33:26 - S-I-0000686
	
	Модифицированность = Ложь;
	
	ТаблицаWarehouseToLegalEntity = LocalDistributionСервер.ПолучитьДанныеWarehouseToLegalEntity(МассивParcels, TripFinalDestinations);
	СтруктураПоиска = Новый Структура("WarehouseTo, LegalEntity");
	
	// Удалим старые строки
	ы = 0;
	Пока ы < TripFinalDestinations.Количество() Цикл
		
		СтрокаТЧ = TripFinalDestinations[ы];
		Если НЕ ЗначениеЗаполнено(СтрокаТЧ.WarehouseTo) Тогда
			TripFinalDestinations.Удалить(СтрокаТЧ);
			Модифицированность = Истина;
		Иначе
			
			ЗаполнитьЗначенияСвойств(СтруктураПоиска, СтрокаТЧ);
			Если ТаблицаWarehouseToLegalEntity.НайтиСтроки(СтруктураПоиска).Количество() = 0 Тогда
				TripFinalDestinations.Удалить(СтрокаТЧ);
				Модифицированность = Истина;
			Иначе
				ы = ы + 1;
			КонецЕсли;
			
		КонецЕсли;
		
	КонецЦикла;
		
	// Добавим новые строки
	//СтруктураПоиска = Новый Структура("WarehouseTo");
	Для Каждого ТекСтрока Из ТаблицаWarehouseToLegalEntity Цикл
		
		//СтруктураПоиска.WarehouseTo = WarehouseTo;
		ЗаполнитьЗначенияСвойств(СтруктураПоиска, ТекСтрока);
		НайденныеСтроки = TripFinalDestinations.НайтиСтроки(СтруктураПоиска);
		Если НайденныеСтроки.Количество() = 0 Тогда
			НоваяСтрока = TripFinalDestinations.Добавить();
			ЗаполнитьЗначенияСвойств(НоваяСтрока, ТекСтрока);
			Модифицированность = Истина;
		КонецЕсли;
		
	КонецЦикла;
	   		
	Возврат Модифицированность;
	
КонецФункции
