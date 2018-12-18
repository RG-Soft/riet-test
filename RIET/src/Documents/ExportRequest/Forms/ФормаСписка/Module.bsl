
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Отбор = Параметры.Отбор;
	
	// Установим отбор по process level и по country
	ProcessLevel = РГСофтСерверПовтИспСеанс.ПолучитьЗначениеРеквизита(ПараметрыСеанса.ТекущийПользователь, "ProcessLevel");
	
	Если ЗначениеЗаполнено(ProcessLevel) Тогда
		
		МассивProcessLevels = Новый Массив;
		МассивProcessLevels.Добавить(ProcessLevel);
		МассивProcessLevels.Добавить(Справочники.ProcessLevels.ПустаяСсылка());
		Отбор.Вставить("ProcessLevel", МассивProcessLevels);
		
		Country = РГСофтСерверПовтИспСеанс.ПолучитьЗначениеРеквизита(ProcessLevel, "Country");
		Если ЗначениеЗаполнено(Country) Тогда
			
			МассивCountries = Новый Массив;
			МассивCountries.Добавить(Country);
			МассивCountries.Добавить(Справочники.CountriesOfProcessLevels.ПустаяСсылка());	
			Отбор.Вставить("FromCountry", МассивCountries);	
			
		КонецЕсли;		
						
	КонецЕсли;
	
КонецПроцедуры
