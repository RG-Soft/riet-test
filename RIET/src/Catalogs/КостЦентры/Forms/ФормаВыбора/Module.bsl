
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Если Параметры.Свойство("СтруктураНастройки") Тогда
		
		СтруктураНастройки = Параметры.СтруктураНастройки;
		Если СтруктураНастройки.Имя = "ВыборИзAUsAndBORGs" Тогда
			НастроитьДляВыбораИзAUsAndBORGs(СтруктураНастройки);
		КонецЕсли;
		
	КонецЕсли;
	
	Отбор = Параметры.Отбор;
	
	Отбор.Вставить("ПометкаУдаления", Ложь);
	
	//[РКХ->]
	ParentCompanyPA = Справочники.SoldTo.НайтиПоКоду("PA");
	Если ЗначениеЗаполнено(ParentCompanyPA) Тогда  
		Список.Параметры.УстановитьЗначениеПараметра("ParentCompanyPA", Справочники.SoldTo.НайтиПоКоду("PA"));
	КонецЕсли;
	//[<-РКХ]
	
КонецПроцедуры

&НаСервере
Процедура НастроитьДляВыбораИзAUsAndBORGs(СтруктураНастройки)
	
	Если ЗначениеЗаполнено(СтруктураНастройки.BORG) Тогда
		
		Запрос = Новый Запрос;
		Запрос.УстановитьПараметр("BORG", СтруктураНастройки.BORG);
		Запрос.Текст = 
			"ВЫБРАТЬ
			|	AUsAndBORGs.AU
			|ИЗ
			|	Справочник.BORGs КАК BORGs
			|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ РегистрСведений.AUsAndBORGs КАК AUsAndBORGs
			|		ПО BORGs.Ссылка <> AUsAndBORGs.BORG
			|			И BORGs.Компания = AUsAndBORGs.BORG.Компания
			|ГДЕ
			|	BORGs.Ссылка = &BORG";
			
		МассивЗапрещенныхAUs = Запрос.Выполнить().Выгрузить().ВыгрузитьКолонку("AU");
		Если МассивЗапрещенныхAUs.Количество() Тогда
			
			СписокЗапрещенныхAUs = Новый СписокЗначений;
			СписокЗапрещенныхAUs.ЗагрузитьЗначения(МассивЗапрещенныхAUs);
			
			ОбщегоНазначенияКлиентСервер.УстановитьЭлементОтбора(
				Список.Отбор,
				"Ссылка",
				СписокЗапрещенныхAUs,
				ВидСравненияКомпоновкиДанных.НеВСписке,
				,
				Истина);
			
		КонецЕсли; 
				
	КонецЕсли; 
	
КонецПроцедуры 