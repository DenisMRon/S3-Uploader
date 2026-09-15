unit model;

interface

type

  TLoadStatus = (tlsReady, tlsSetup, tlsInProgress, tlsDone, tlsStop, tlsError);
const
  TLoadStatusName: array[TLoadStatus] of string = ('Подготовлен', 'Нaстройка', 'Грузится', 'Загружен', 'Прерван', 'Ошибка');

type
  TEventType = (tetOnReady, tetOnStart, tetOnprogress, tetOnFinish, tetOnError);
  TSettingsEventType = (tsetSettingChange);

implementation

end.
