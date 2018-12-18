
#Область ПЕРМЕННЫЕ_ПЛАТФОРМЫ

&НаКлиенте
Перем Платформа Экспорт, Манифест Экспорт;

&НаКлиенте
Перем НомерИтерацииВызоваМодуля;

&НаСервере
Перем ОбработкаОбъект;

#КонецОбласти

#Область ПРОЦЕДУРЫ_И_ФУНКЦИИ_ПЛАТФОРМЫ

&НаКлиенте
Функция МетодКлиента(ИмяМодуля= "", ИмяМетода, 
		Параметр0= NULL, Параметр1= NULL, Параметр2= NULL, Параметр3= NULL, Параметр4= NULL, 
		Параметр5= NULL, Параметр6= NULL, Параметр7= NULL, Параметр8= NULL, Параметр9= NULL)
	
	Возврат  Платформа.МетодКлиента(ИмяМодуля, ИмяМетода, 
	Параметр0, Параметр1, Параметр2, Параметр3, Параметр4, 
	Параметр5, Параметр6, Параметр7, Параметр8, Параметр9);
	
КонецФункции

&НаСервере
Функция МетодСервера(Знач ИмяМодуля= "", Знач ИмяМетода,
		Параметр0= NULL, Параметр1= NULL, Параметр2= NULL, Параметр3= NULL, Параметр4= NULL, 
		Параметр5= NULL, Параметр6= NULL, Параметр7= NULL, Параметр8= NULL, Параметр9= NULL)
	
	Возврат ОбработкаОбъект().МетодСервера(ИмяМодуля, ИмяМетода, 
	Параметр0, Параметр1, Параметр2, Параметр3, Параметр4, 
	Параметр5, Параметр6, Параметр7, Параметр8, Параметр9);
	
КонецФункции

&НаСервере
Функция ОбработкаОбъект()
	
	Если ОбработкаОбъект = Неопределено Тогда
		ОбработкаОбъект= РеквизитФормыВЗначение("Объект");
	КонецЕсли;
	
	Возврат ОбработкаОбъект;
	
КонецФункции

&НаКлиенте
Процедура Инициализировать(ИмяМодуля) Экспорт
	
	Если НомерИтерацииВызоваМодуля = Неопределено Тогда
		НомерИтерацииВызоваМодуля= 0;
	КонецЕсли;
	
	НомерИтерацииВызоваМодуля= НомерИтерацииВызоваМодуля + 1;
	
	Если Манифест = Неопределено Тогда
		Платформа.ЗаполнитьМанифест(ЭтаФорма, ИмяМодуля);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ОчиститьПеременные() Экспорт
	
	// Разрывается циклическая ссылка, для того чтобы исключить утечку памяти.
	// Модуль может быть вызван повторно во вложенных методах,
	// поэтому очищаем переменные, ТОЛЬКО если это начальная итерация вызова модуля.
	
	НомерИтерацииВызоваМодуля= НомерИтерацииВызоваМодуля - 1;
	
	Если НомерИтерацииВызоваМодуля = 0 Тогда
		Платформа= 					  Неопределено;
		Объект.ПараметрыКлиентСервер= Неопределено;
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область МАНИФЕСТ

// Все функции и процедуры тела модуля должны быть экспортными и добавлены в соответствующую структуру!

&НаКлиенте
Функция ФункцииМодуля() Экспорт
	
	СтруктураМетодов= Новый Структура;
	
	// Шаблон: Платформа.ДобавитьФункциюВМанифест(СтруктураМетодов, <Имя функции>, <Параметры строкой>, <Вариант кэширования>, <Переопределение>);
	//Платформа.ДобавитьФункциюВМанифест(СтруктураМетодов, "ПримерФункции", "ОбязательныйПараметр, НеобязательныйПараметр= Неопределено", "НеИспользовать", Истина);
	//Платформа.ДобавитьФункциюВМанифест(СтруктураМетодов, "ПримерФункции", "ОбязательныйПараметр, НеобязательныйПараметр= Неопределено", "НаВремяВыполнения", Истина);
	//Платформа.ДобавитьФункциюВМанифест(СтруктураМетодов, "ПримерФункции", "ОбязательныйПараметр, НеобязательныйПараметр= Неопределено", "НаВремяСеанса", Истина);
	//...
	Платформа.ДобавитьФункциюВМанифест(СтруктураМетодов, "КартинкаБиблиотеки", "ИмяКартинки", "НеИспользовать", Истина);
	
	Возврат СтруктураМетодов;
	
КонецФункции

&НаКлиенте
Функция ПроцедурыМодуля() Экспорт
	
	СтруктураМетодов= Новый Структура;
	
	// Шаблон: Платформа.ДобавитьПроцедуруВМанифест(СтруктураМетодов, <Имя процедуры>, <Параметры строкой>, <Переопределение>);
	//Платформа.ДобавитьПроцедуруВМанифест(СтруктураМетодов, "ПримерПроцедуры", "ОбязательныйПараметр, НеобязательныйПараметр= Неопределено", Истина);
	//...
	
	Возврат СтруктураМетодов;
	
КонецФункции

#КонецОбласти

&НаКлиенте
Функция КартинкаБиблиотеки(ИмяКартинки) Экспорт
	
	Возврат Элементы.Найти(ИмяКартинки).Картинка;
	
КонецФункции

