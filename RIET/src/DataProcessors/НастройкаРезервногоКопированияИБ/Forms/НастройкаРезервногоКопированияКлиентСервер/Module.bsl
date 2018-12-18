
#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Если ОбщегоНазначенияКлиентСервер.ЭтоВебКлиент() Тогда
		ВызватьИсключение ВернутьСтр("ru = 'Резервное копирование недоступно в веб-клиенте.'");
	КонецЕсли;
	
	Если ОбщегоНазначенияКлиентСервер.ЭтоLinuxКлиент() Тогда
		Возврат; // Отказ устанавливается в ПриОткрытии().
	КонецЕсли;
	
	ПараметрыРезервногоКопирования = РезервноеКопированиеИБСервер.ПараметрыРезервногоКопирования();
	ОтключитьНапоминания = ПараметрыРезервногоКопирования.РезервноеКопированиеНастроено;
	
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	Если ОбщегоНазначенияКлиентСервер.ЭтоLinuxКлиент() Тогда
		Отказ = Истина;
		ТекстСообщения = ВернутьСтр("ru = 'Резервное копирование не поддерживается в клиенте под управлением ОС Linux.'");
		ПоказатьПредупреждение(, ТекстСообщения);
		Возврат;
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура ОК(Команда)
	
	ПараметрыПриложения["СтандартныеПодсистемы.ПараметрыРезервногоКопированияИБ"].ПараметрОповещения =
		?(ОтключитьНапоминания, "НеОповещать", "ЕщеНеНастроено");
	
	Если ОтключитьНапоминания Тогда
		РезервноеКопированиеИБКлиент.ОтключитьОбработчикОжиданияРезервногоКопирования();
	Иначе
		РезервноеКопированиеИБКлиент.ПодключитьОбработчикОжиданияРезервногоКопирования();
	КонецЕсли;
	
	ОКНаСервере();
	Оповестить("ЗакрытаФормаНастройкиРезервногоКопирования");
	Закрыть();
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаСервере
Процедура ОКНаСервере()
	
	ПараметрыРезервногоКопирования = РезервноеКопированиеИБСервер.ПараметрыРезервногоКопирования();
	
	ПараметрыРезервногоКопирования.РезервноеКопированиеНастроено = ОтключитьНапоминания;
	ПараметрыРезервногоКопирования.ВыполнятьАвтоматическоеРезервноеКопирование = Ложь;
	
	РезервноеКопированиеИБСервер.УстановитьПараметрыРезервногоКопирования(ПараметрыРезервногоКопирования);
	
КонецПроцедуры

#КонецОбласти
