////////////////////////////////////////////////////////////////////////////////
// ОБРАБОТЧИКИ СОБЫТИЙ ФОРМЫ

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Отказ = Истина;
	//ПрисоединенныеФайлы.ПриСозданииНаСервереПрисоединенныйФайл(ЭтаФорма);
	
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// СЛУЖЕБНЫЕ ПРОЦЕДУРЫ И ФУНКЦИИ

&НаКлиенте
Процедура Подключаемый_ПерейтиКФормеФайла(Команда)
	
	ПрисоединенныеФайлыКлиент.ПерейтиКФормеПрисоединенногоФайла(ЭтаФорма);
	
КонецПроцедуры
