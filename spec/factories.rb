FactoryGirl.define do
  factory :user do
    username "arto"
    sex "m"
    handedness "r"
    yearOfBirth "1983"
    education "peruskoulu"
  end

  factory :user2, class: User do
    username "maija"
    sex "f"
    handedness "l"
    yearOfBirth "1902"
    education "yo"
  end

  factory :list do
    filename "list1"
    training false
    active true
  end

  factory :trainingList, class: List do
    filename "treenilista"
    training true
    active true
  end

  factory :inactiveList, class: List do
    filename "treenilista"
    training false
    active false
  end

  factory :list2, class: List do
    filename "list2"
    training false
    active true
  end

  factory :list3, class: List do
    filename "list3"
    training false
    active true
  end

end