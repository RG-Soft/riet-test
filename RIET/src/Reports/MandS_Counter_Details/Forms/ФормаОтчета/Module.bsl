
&НаКлиенте
Процедура ShowFilters(Команда)
	
	Элементы.ShowFilters.Пометка = НЕ Элементы.ShowFilters.Пометка;
	Элементы.КомпоновщикНастроекПользовательскиеНастройки.Видимость = Элементы.ShowFilters.Пометка;
		
КонецПроцедуры


&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	
	
КонецПроцедуры


&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	//СкомпоноватьРезультат();
	
КонецПроцедуры

