//#Если НЕ Клиент И НЕ ВнешнееСоединение Тогда

// Функция возвращает значение экспортных переменных модуля приложений
//
// Параметры
//  ИмяПеременной - строка, содержит имя переменной целиком 
//
// Возвращаемое значение:
//   значение соответствующей экспортной переменной
//
//Функция СтрНайти(Строка,ПодстрокаПоиска) Экспорт
//	
//	Возврат Найти(Строка,ПодстрокаПоиска);
//	      
//КонецФункции

//Функция СтрШаблон(СтрокаШаблон, Параметр1 = Неопределено, Параметр2 = Неопределено, Параметр3= Неопределено, Параметр4 = Неопределено) Экспорт

//	Для НомерПараметра=1 По 4 Цикл
//	    текПараметр = Вычислить("Параметр"+Строка(НомерПараметра));
//		Если ЗначениеЗаполнено(текПараметр) Тогда 
//			СтрокаШаблон = СтрЗаменить(СтрокаШаблон, "%"+Строка(НомерПараметра),текПараметр);
//		КонецЕсли;
//	
//	КонецЦикла;
//	
//	Возврат СтрокаШаблон;
//	
//КонецФункции

//Функция СтрРазделить(Строка, Разделитель, параметр) Экспорт 
//	
//	Возврат СтроковыеФункцииКлиентСервер.РазложитьСтрокуВМассивПодстрок(Строка, Разделитель,Истина,Истина);
//	
//КонецФункции
	
//#КонецЕсли

// функция для замены глобального метода НСтр 
// возвращает значение для всех языков
Функция ВернутьСтр(Знач ТекстСтроки, Знач КодЯзыка = Неопределено) Экспорт 
	
	Если СтрНайти(НРег(ТекстСтроки), "ru = '") > 0 ИЛИ СтрНайти(НРег(ТекстСтроки), "ru='") Тогда 
		Возврат НСтр(ТекстСтроки, ОбщегоНазначенияКлиентСервер.КодОсновногоЯзыка());
	Иначе 
		Возврат ТекстСтроки;     
	КонецЕсли;

КонецФункции

// { RGS LFedotova 12.03.2017 23:51:18 - вопрос SLI-0007202
Процедура ВыполнитьЗагрузкуAU() Экспорт
	
	//Если Час(ТекущаяДата()) >= 12 И Час(ТекущаяДата()) <= 23 Тогда
	//	Если Константы.ВыполнятьЗагрузкуAU.Получить() Тогда
	//		Константы.ВыполнятьЗагрузкуAU.Установить(Ложь);
	//		РГСофт.ЗагрузитьAccountingUnitsИзAU_master_клиент();	
	//	КонецЕсли;
	//Иначе
	//	Если НЕ Константы.ВыполнятьЗагрузкуAU.Получить() Тогда
	//		Константы.ВыполнятьЗагрузкуAU.Установить(Истина);
	//	КонецЕсли;
	//КонецЕсли;

КонецПроцедуры
// } RGS LFedotova 12.03.2017 23:51:40 - вопрос SLI-0007202
 