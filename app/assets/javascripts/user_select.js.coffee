$ ->
 $("select[name=user]").change ->
    self.location.href = $(":selected", this).data("link")
