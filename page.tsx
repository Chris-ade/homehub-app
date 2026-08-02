"use client";

import React, { useState, useEffect, useRef } from "react";
import { useAuth } from "@/context/AuthContext";
import { lgaList } from "@/components/location-selector";
import { useApiQuery, useApiMutation } from "@/hooks/useApi";
import { useRouter } from "next/navigation";
import useTitle from "@/hooks/useTitle";
import { useProfilePictureUpload } from "@/hooks/useProfilePictureUpload";
import { useToast } from "@/hooks/useToast";
import { UserPicture } from "../../partials/user-picture";
import { JWTUser, User } from "@/types/auth";
import PrivateRoute from "@/services/auth/route";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import {
  Select,
  SelectContent,
  SelectGroup,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { Button } from "@/components/ui/button";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import { Alert, AlertDescription } from "@/components/ui/alert";
import {
  User as UserIcon,
  Phone,
  Briefcase,
  MapPin,
  Camera,
  Save,
  Loader2,
  Info,
  Eye,
  ArrowLeft,
} from "lucide-react";
import Link from "next/link";

interface FormErrors {
  [key: string]: string[];
}

const UpdateAccount = () => {
  useTitle("Update Profile - RentalHub");
  const { user, setUser } = useAuth();
  const navigate = useRouter();
  const { uploadProfilePicture, isUploading, uploadProgress } =
    useProfilePictureUpload();
  const mutation = useApiMutation();
  const { toastSuccess, toastError } = useToast();

  const [modalShow, setModalShow] = useState(false);
  const fileInputRef = useRef<HTMLInputElement | null>(null);
  const [previewSrc, setPreviewSrc] = useState<string | undefined>(undefined);
  const [formErrors, setFormErrors] = useState<FormErrors | null>();
  const [userData, setUserData] = useState<User | null>(null);

  const [editableData, setEditableData] = useState({
    first_name: "",
    last_name: "",
    mobile: "",
    occupation: "",
    lga: "",
    state: "",
  });

  const [selectedState, setSelectedState] = useState("");
  const [selectedLGA, setSelectedLGA] = useState("");

  const { isLoading, data } = useApiQuery<User>(`/users/${user?.id}`);

  useEffect(() => {
    if (data) {
      setUserData(data);
    }
  }, [data]);

  const handleInputChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const { id, value } = e.target;
    setEditableData((prevData) => ({
      ...prevData,
      [id]: value,
    }));
  };

  const handleStateChange = (value: string) => {
    setSelectedState(value);
    setSelectedLGA("");
    setEditableData((prev) => ({
      ...prev,
      state: value,
      lga: "",
    }));
  };

  const handleLGAChange = (value: string) => {
    setSelectedLGA(value);
    setEditableData((prev) => ({
      ...prev,
      lga: value,
    }));
  };

  const handleSave = async () => {
    setFormErrors(null);
    try {
      const payload = {
        first_name: editableData.first_name,
        last_name: editableData.last_name,
        mobile: editableData.mobile,
        occupation: editableData.occupation,
        lga: editableData.lga,
        state: editableData.state,
      };

      const result = await mutation.mutateAsync({
        url: `/users/${user?.id}`,
        method: "PUT",
        data: payload,
      });

      setUser(result as JWTUser);
      toastSuccess("Profile updated successfully!");
      navigate.push(`/profile`);
    } catch (error: any) {
      if (error.errors) {
        setFormErrors(error.errors);
      } else {
        toastError(error.message || "Failed to update profile");
      }
    }
  };

  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (file) {
      if (
        !["image/jpeg", "image/jpg", "image/png", "image/webp"].includes(
          file.type,
        )
      ) {
        toastError(
          "Invalid file type. Only JPEG, PNG, and WebP images are allowed.",
        );
        return;
      }
      if (file.size > 5 * 1024 * 1024) {
        toastError("File size exceeds 5MB limit.");
        return;
      }

      const reader = new FileReader();
      reader.onload = (event) => {
        setPreviewSrc(event.target?.result as string);
        setModalShow(true);
      };
      reader.readAsDataURL(file);
    }
  };

  const handleUpload = async () => {
    const file = fileInputRef.current?.files?.[0];
    if (!file || !userData) return;

    try {
      const response = await uploadProfilePicture(userData.id, file);

      if (response && response.avatar) {
        setUser((prevUser) =>
          prevUser ? { ...prevUser, avatar: response.avatar || null } : null,
        );

        setUserData((prev) =>
          prev ? { ...prev, avatar: response.avatar || null } : null,
        );

        toastSuccess("Profile picture updated successfully!");
        setModalShow(false);
        setPreviewSrc(undefined);

        if (fileInputRef.current) {
          fileInputRef.current.value = "";
        }
      }
    } catch (error: any) {
      toastError(error.message || "Failed to upload profile picture");
    }
  };

  useEffect(() => {
    if (userData) {
      setEditableData({
        first_name: userData.first_name || "",
        last_name: userData.last_name || "",
        mobile: userData.mobile || "",
        occupation: userData.occupation || "",
        lga: userData.lga || "",
        state: userData.state || "",
      });
      setSelectedState(userData.state || "");
      setSelectedLGA(userData.lga || "");
    }
  }, [userData]);

  return (
    <PrivateRoute>
      <div className="min-h-screen bg-background text-foreground">
        <div className="container-x py-10 max-w-5xl">
          {/* Back nav */}
          <Link
            href="/profile"
            className="inline-flex items-center gap-2 text-sm font-medium text-muted-foreground mb-8 hover:text-foreground transition-colors"
          >
            <ArrowLeft className="h-4 w-4" /> Back to Profile
          </Link>

          {/* Header */}
          <div className="mb-8">
            <h1 className="mt-2 font-heading font-black tracking-tight text-primary text-2xl sm:text-3xl">
              Update Profile
            </h1>
            <p className="mt-2 text-sm text-muted-foreground">
              Manage your personal information and preferences.
            </p>
          </div>

          <div className="grid lg:grid-cols-3 gap-6">
            {/* Sidebar - Info Cards */}
            <div className="lg:col-span-1 space-y-4">
              <div className="rounded-2xl border border-border bg-card p-5 shadow-xs">
                <div className="flex items-center gap-2 mb-3">
                  <div className="grid h-9 w-9 place-items-center rounded-xl bg-primary/10 text-primary">
                    <Info className="h-4 w-4" />
                  </div>
                  <p className="font-heading font-bold text-md text-foreground">
                    Editable Fields
                  </p>
                </div>
                <p className="text-sm leading-relaxed text-muted-foreground">
                  You can update your full name, profile picture, location (LGA,
                  State), phone number, and occupation.
                </p>
              </div>

              <div className="rounded-2xl border border-border bg-card p-5 shadow-xs">
                <div className="flex items-center gap-2 mb-3">
                  <div className="grid h-9 w-9 place-items-center rounded-xl bg-primary/10 text-primary">
                    <Eye className="h-4 w-4" />
                  </div>
                  <p className="font-heading font-bold text-md text-foreground">
                    Privacy Info
                  </p>
                </div>
                <p className="text-sm leading-relaxed text-muted-foreground">
                  Only your full name, location, phone number, and occupation
                  are shared with agents.
                </p>
              </div>
            </div>

            {/* Main Form */}
            <div className="lg:col-span-2">
              <div className="rounded-2xl border border-border bg-card p-6 shadow-xs">
                <h2 className="font-heading font-bold text-xl text-primary mb-6">
                  Personal Information
                </h2>
                {isLoading ? (
                  <div className="flex items-center justify-center py-12">
                    <div className="text-center space-y-3">
                      <Loader2 className="h-10 w-10 animate-spin mx-auto text-primary" />
                      <p className="text-sm text-muted-foreground">
                        Loading profile data…
                      </p>
                    </div>
                  </div>
                ) : userData ? (
                  <div className="space-y-6">
                    {/* Profile Picture */}
                    <div className="flex flex-col items-center gap-4 pb-6 border-b border-border">
                      <div className="relative group">
                        <UserPicture
                          user={userData}
                          src={userData.avatar}
                          alt={userData.first_name || "User"}
                          size="xl"
                          fallbackText={`${userData.first_name || ""} ${
                            userData.last_name || ""
                          }`}
                        />
                        <button
                          type="button"
                          onClick={() => fileInputRef.current?.click()}
                          className="absolute bottom-0 right-0 p-2 bg-primary text-primary-foreground rounded-full shadow-lg hover:bg-primary/90 transition-colors"
                          title="Change Profile Picture"
                        >
                          <Camera className="h-4 w-4" />
                        </button>
                      </div>
                      <input
                        ref={fileInputRef}
                        type="file"
                        accept="image/jpeg,image/jpg,image/png,image/webp"
                        onChange={handleFileChange}
                        className="hidden"
                      />
                      <p className="text-xs text-muted-foreground text-center">
                        Click the camera icon to update your profile picture
                      </p>
                    </div>

                    {/* Form Fields */}
                    <div className="grid sm:grid-cols-2 gap-4">
                      {/* First Name */}
                      <div>
                        <Label htmlFor="first_name">First Name</Label>
                        <div className="relative mt-2">
                          <UserIcon className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
                          <Input
                            id="first_name"
                            value={editableData.first_name}
                            onChange={handleInputChange}
                            placeholder="First Name"
                            className="pl-10 h-11"
                          />
                        </div>
                        {formErrors?.first_name && (
                          <Alert variant="destructive" className="mt-2">
                            <AlertDescription>
                              {formErrors.first_name.join(", ")}
                            </AlertDescription>
                          </Alert>
                        )}
                      </div>

                      {/* Last Name */}
                      <div>
                        <Label htmlFor="last_name">Last Name</Label>
                        <div className="relative mt-2">
                          <UserIcon className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
                          <Input
                            id="last_name"
                            value={editableData.last_name}
                            onChange={handleInputChange}
                            placeholder="Last Name"
                            className="pl-10 h-11"
                          />
                        </div>
                        {formErrors?.last_name && (
                          <Alert variant="destructive" className="mt-2">
                            <AlertDescription>
                              {formErrors.last_name.join(", ")}
                            </AlertDescription>
                          </Alert>
                        )}
                      </div>

                      {/* Mobile */}
                      <div>
                        <Label htmlFor="mobile">Phone Number</Label>
                        <div className="relative mt-2">
                          <Phone className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
                          <Input
                            id="mobile"
                            value={editableData.mobile}
                            onChange={handleInputChange}
                            placeholder="Phone Number"
                            className="pl-10 h-11"
                          />
                        </div>
                        {formErrors?.mobile && (
                          <Alert variant="destructive" className="mt-2">
                            <AlertDescription>
                              {formErrors.mobile.join(", ")}
                            </AlertDescription>
                          </Alert>
                        )}
                      </div>

                      {/* Occupation */}
                      <div>
                        <Label htmlFor="occupation">Occupation</Label>
                        <div className="relative mt-2">
                          <Briefcase className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
                          <Input
                            id="occupation"
                            value={editableData.occupation}
                            onChange={handleInputChange}
                            placeholder="Occupation"
                            className="pl-10 h-11"
                          />
                        </div>
                        {formErrors?.occupation && (
                          <Alert variant="destructive" className="mt-2">
                            <AlertDescription>
                              {formErrors.occupation.join(", ")}
                            </AlertDescription>
                          </Alert>
                        )}
                      </div>

                      {/* State */}
                      <div>
                        <Label>State</Label>
                        <Select
                          value={selectedState}
                          onValueChange={handleStateChange}
                        >
                          <SelectTrigger className="h-11 mt-2">
                            <SelectValue placeholder="Select State" />
                          </SelectTrigger>
                          <SelectContent>
                            <SelectGroup>
                              {Object.keys(lgaList).map((state, index) => (
                                <SelectItem value={state} key={index}>
                                  {state}
                                </SelectItem>
                              ))}
                            </SelectGroup>
                          </SelectContent>
                        </Select>
                        {formErrors?.state && (
                          <Alert variant="destructive" className="mt-2">
                            <AlertDescription>
                              {formErrors.state.join(", ")}
                            </AlertDescription>
                          </Alert>
                        )}
                      </div>

                      {/* LGA */}
                      {selectedState && (
                        <div>
                          <Label>LGA / City</Label>
                          <Select
                            value={selectedLGA}
                            onValueChange={handleLGAChange}
                          >
                            <SelectTrigger className="h-11 mt-2">
                              <SelectValue placeholder="Select LGA" />
                            </SelectTrigger>
                            <SelectContent>
                              <SelectGroup>
                                {lgaList[selectedState]?.map((lga, index) => (
                                  <SelectItem value={lga} key={index}>
                                    {lga}
                                  </SelectItem>
                                ))}
                              </SelectGroup>
                            </SelectContent>
                          </Select>
                          {formErrors?.lga && (
                            <Alert variant="destructive" className="mt-2">
                              <AlertDescription>
                                {formErrors.lga.join(", ")}
                              </AlertDescription>
                            </Alert>
                          )}
                        </div>
                      )}
                    </div>

                    {/* Save Button */}
                    <div className="flex justify-end pt-4">
                      <Button
                        onClick={handleSave}
                        disabled={mutation.isPending}
                        className="h-11 px-6 rounded-xl text-sm font-semibold bg-primary text-primary-foreground hover:bg-primary/90 shadow-md"
                      >
                        {mutation.isPending ? (
                          <>
                            <Loader2 className="mr-2 h-4 w-4 animate-spin" />{" "}
                            Saving…
                          </>
                        ) : (
                          <>
                            <Save className="mr-2 h-4 w-4" /> Save Changes
                          </>
                        )}
                      </Button>
                    </div>
                  </div>
                ) : (
                  <div className="text-center py-12">
                    <p className="text-muted-foreground">
                      No profile data found.
                    </p>
                  </div>
                )}
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Image Preview Dialog */}
      <Dialog open={modalShow} onOpenChange={setModalShow}>
        <DialogContent className="max-w-2xl max-h-[90vh] overflow-y-auto">
          <DialogHeader>
            <DialogTitle>Preview Profile Picture</DialogTitle>
            <DialogDescription>
              Review your photo before uploading
            </DialogDescription>
          </DialogHeader>
          <div className="space-y-4">
            <div className="flex items-center justify-center rounded-xl p-8 bg-muted/40">
              {previewSrc && (
                <img
                  src={previewSrc}
                  alt="Preview"
                  className="max-h-96 rounded-xl object-contain"
                />
              )}
            </div>
            <div className="rounded-xl p-4 bg-muted/30 border border-border">
              <h4 className="font-semibold mb-2 flex items-center gap-2">
                <Info className="h-4 w-4 text-primary" />
                Photo Guidelines
              </h4>
              <ul className="space-y-1 text-sm text-muted-foreground ml-6 list-disc">
                <li>Your face is well-lit, not blurry, and fills the frame</li>
                <li>
                  You&apos;re facing forward and are the only person in your
                  photo
                </li>
                <li>
                  Your photo doesn&apos;t feature animals or landscapes instead
                  of you
                </li>
              </ul>
            </div>
          </div>
          {isUploading && (
            <div className="space-y-2">
              <div className="flex justify-between text-sm">
                <span>Uploading...</span>
                <span>{uploadProgress}%</span>
              </div>
              <div className="h-2 bg-secondary rounded-full overflow-hidden">
                <div
                  className="h-full bg-primary transition-all duration-300"
                  style={{ width: `${uploadProgress}%` }}
                />
              </div>
            </div>
          )}
          <DialogFooter>
            <Button
              variant="outline"
              onClick={() => setModalShow(false)}
              disabled={isUploading}
            >
              Cancel
            </Button>
            <Button onClick={handleUpload} disabled={isUploading}>
              {isUploading ? (
                <>
                  <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                  Uploading...
                </>
              ) : (
                "Upload Photo"
              )}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </PrivateRoute>
  );
};

export default UpdateAccount;
