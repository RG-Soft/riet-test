
Процедура ПриЗаписи(Отказ, Замещение)
	// { RGS EParshina 08.10.2018 19:14:04 - S-I-0005914	
	//Для Каждого Запись из ЭтотОбъект Цикл 
	//	
	//	Запрос = Новый Запрос;
	//	Запрос.Текст = "ВЫБРАТЬ
	//	|	AU_Planners.Planner КАК Planner
	//	|ИЗ
	//	|	РегистрСведений.AU_Planners КАК AU_Planners
	//	|ГДЕ
	//	|	AU_Planners.AU = &AU
	//	|	И AU_Planners.Planner <> &Planner
	//	|
	//	|СГРУППИРОВАТЬ ПО
	//	|	AU_Planners.Planner";
	//	Запрос.УстановитьПараметр("Planner", Запись.Planner);
	//	Запрос.УстановитьПараметр("AU", Запись.AU);
	//	
	//	Результат = Запрос.Выполнить().Выгрузить();
	//	Если Результат.Количество() >= 2 Тогда
	//		ОбщегоНазначенияКлиентСервер.СообщитьПользователю("По AU - " + Запись.AU + " в каталоге уже имеются две записи");
	//		Отказ = Истина;
	//	КонецЕсли;
	//	
	//КонецЦикла;
	// } RGS EParshina 08.10.2018 19:14:04 - S-I-0005914
КонецПроцедуры
