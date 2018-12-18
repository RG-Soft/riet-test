
&НаСервере
Процедура ПередЗаписьюНаСервере(Отказ, ТекущийОбъект, ПараметрыЗаписи)
	
	// { RGS AArsentev S-I-0001800 22.28.2016 10:22:52	
	Если НЕ ЗначениеЗаполнено(Запись.SpecifyCostCenter) Тогда
		 Отказ = Истина;
		 Сообщить("Не выбрано 'Specify cost center'");
	КонецЕсли;
	 
	Если Запись.SpecifyCostCenter = Перечисления.TypesOfCostCenters.FromSegment и НЕ Запись.SpecifySegment Тогда
		Отказ = Истина;
		Сообщить("Не установлено свойство 'Specify Segment'");
	КонецЕсли;
	
	Если Запись.SpecifyCostCenter = Перечисления.TypesOfCostCenters.FromLegalEntity_ProductLine и НЕ Запись.SpecifyProductLine Тогда
		Отказ = Истина;
		Сообщить("Не установлено свойство 'Specify Product Line'");
	КонецЕсли; 
	
	Если Запись.SpecifyCostCenter = Перечисления.TypesOfCostCenters.DefaultCostCenter и НЕ ЗначениеЗаполнено(Запись.DefaultCostCenter) Тогда
		Отказ = Истина;
		Сообщить("Не выбран 'Default cost center'");
	КонецЕсли;
	 
    // } RGS AArsentev S-I-0001800 22.28.2016 10:22:52	
	РГСофт.ЗаполнитьModification(ТекущийОбъект);
	
КонецПроцедуры

&НаКлиенте
Процедура SpecifyCostCenterПриИзменении(Элемент)
	
	Если Запись.SpecifyCostCenter = ПредопределенноеЗначение("Перечисление.TypesOfCostCenters.DefaultCostCenter") Тогда 
		Элементы.DefaultCostCenter.Видимость = Истина;
	Иначе
		Элементы.DefaultCostCenter.Видимость = Ложь;	
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	Если Запись.SpecifyCostCenter = ПредопределенноеЗначение("Перечисление.TypesOfCostCenters.DefaultCostCenter") Тогда 
		Элементы.DefaultCostCenter.Видимость = Истина;
	Иначе
		Элементы.DefaultCostCenter.Видимость = Ложь;	
	КонецЕсли;
	
КонецПроцедуры
