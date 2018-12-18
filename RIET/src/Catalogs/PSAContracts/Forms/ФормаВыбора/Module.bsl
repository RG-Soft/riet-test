
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Отбор = Параметры.Отбор;
	
	Отбор.Вставить("ПометкаУдаления", Ложь);
	
	Если НЕ Отбор.Свойство("Country") Тогда
		
		UserCountry = ImportExportСервер.ПолучитьCountryПользователя(ПараметрыСеанса.ТекущийПользователь);
		Если ЗначениеЗаполнено(UserCountry) Тогда
			Отбор.Вставить("Country", UserCountry);
		КонецЕсли;
		
	КонецЕсли;
	
КонецПроцедуры
