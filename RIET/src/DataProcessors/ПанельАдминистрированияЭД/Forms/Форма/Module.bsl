
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Если Параметры.Свойство("АвтоТест") Тогда
		Возврат;
	КонецЕсли;
	
	ВызватьИсключение ВернутьСтр("ru='Обработка не предназначена для непосредственного использования.'");
	
КонецПроцедуры
