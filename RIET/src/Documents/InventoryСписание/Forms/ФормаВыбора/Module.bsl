//Добавила Федотова Л., РГ-Софт, 25.03.13, вопрос SLI-0003435
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Если Параметры.Свойство("Сегмент") Тогда 
		 ОбщегоНазначенияКлиентСервер.УстановитьЭлементОтбора(Список.Отбор,
													"Segment",
													Параметры.Сегмент,
													ВидСравненияКомпоновкиДанных.Равно,
													,Истина,
													РежимОтображенияЭлементаНастройкиКомпоновкиДанных.Авто);
	КонецЕсли;
			 		
КонецПроцедуры
